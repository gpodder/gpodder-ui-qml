#
# gPodder QML UI Reference Implementation
# Copyright (c) 2013, Thomas Perl <m@thp.io>
#
# Permission to use, copy, modify, and/or distribute this software for any
# purpose with or without fee is hereby granted, provided that the above
# copyright notice and this permission notice appear in all copies.
#
# THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
# REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
# AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
# INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
# LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#


import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'gpodder-core', 'src'))

import pyotherside
import gpodder

from gpodder.api import core
from gpodder.api import util

import logging
import functools

logger = logging.getLogger(__name__)

def run_in_background_thread(f):
    """Decorator for functions that take longer to finish

    The function will be run in its own thread, and control
    will be returned to the caller right away, which allows
    other Python code to run while this function finishes.

    The function cannot return a value (control is usually
    returned to the caller before execution is finished).
    """
    @functools.wraps(f)
    def wrapper(*args):
        util.run_in_background(lambda: f(*args))

    return wrapper


class gPotherSide:
    def __init__(self):
        self.core = None
        self._checking_for_new_episodes = False

    def initialize(self, progname):
        assert self.core is None, 'Already initialized'

        self.core = core.Core(progname=progname)
        pyotherside.send('podcast-list-changed')

    def atexit(self):
        self.core.shutdown()

    def _get_episode_by_id(self, episode_id):
        for podcast in self.core.model.get_podcasts():
            for episode in podcast.episodes:
                if episode.id == episode_id:
                    return episode

    def _get_podcast_by_id(self, podcast_id):
        for podcast in self.core.model.get_podcasts():
            if podcast.id == podcast_id:
                return podcast

    def get_stats(self):
        podcasts = self.core.model.get_podcasts()

        total, deleted, new, downloaded, unplayed = 0, 0, 0, 0, 0
        for podcast in podcasts:
            to, de, ne, do, un = podcast.get_statistics()
            total += to
            deleted += de
            new += ne
            downloaded += do
            unplayed += un

        return '\n'.join([
            '%d podcasts' % len(podcasts),
            '%d episodes' % total,
            '%d new episodes' % new,
            '%d downloads' % downloaded,
        ])

    def _get_cover(self, podcast):
        filename = self.core.cover_downloader.get_cover(podcast)
        if not filename:
            return ''
        return 'file://' + filename

    def _get_playback_progress(self, episode):
        if episode.total_time > 0 and episode.current_position > 0:
            return float(episode.current_position) / float(episode.total_time)

        return 0

    def convert_podcast(self, podcast):
        total, deleted, new, downloaded, unplayed = podcast.get_statistics()

        return {
            'id': podcast.id,
            'title': podcast.title,
            'newEpisodes': new,
            'downloaded': downloaded,
            'coverart': self._get_cover(podcast),
            'updating': podcast._updating,
            'section': podcast.section,
        }

    def _get_podcasts_sorted(self):
        return sorted(self.core.model.get_podcasts(),
                key=lambda podcast: (podcast.section, podcast.title))

    def load_podcasts(self):
        podcasts = self._get_podcasts_sorted()
        return [self.convert_podcast(podcast) for podcast in podcasts]

    def convert_episode(self, episode):
        return {
            'id': episode.id,
            'title': episode.trimmed_title,
            'progress': episode.download_progress(),
            'downloadState': episode.state,
            'isNew': episode.is_new,
            'playbackProgress': self._get_playback_progress(episode),
        }

    def load_episodes(self, id):
        podcast = self._get_podcast_by_id(id)
        return [self.convert_episode(episode) for episode in podcast.episodes]

    def get_fresh_episodes_summary(self, count):
        summary = []
        for podcast in self.core.model.get_podcasts():
            _, _, new, _, _ = podcast.get_statistics()
            if new:
                summary.append({
                    'coverart': self._get_cover(podcast),
                    'newEpisodes': new,
                })

        summary.sort(key=lambda e: e['newEpisodes'], reverse=True)
        return summary[:int(count)]

    def convert_fresh_episode(self, episode):
        return {
            'id': episode.id,
            'title': episode.title,
            'podcast': episode.channel.title,
            'published': util.format_date(episode.published),
            'progress': episode.download_progress(),
            'downloadState': episode.state,
        }

    def get_fresh_episodes(self):
        fresh_episodes = []
        for podcast in self.core.model.get_podcasts():
            for episode in podcast.episodes:
                if episode.is_fresh():
                    fresh_episodes.append(episode)

        fresh_episodes.sort(key=lambda e: e.published, reverse=True)
        return [self.convert_fresh_episode(e) for e in fresh_episodes]

    @run_in_background_thread
    def subscribe(self, url):
        url = util.normalize_feed_url(url)
        # TODO: Check if subscription already exists
        self.core.model.load_podcast(url, create=True)
        self.core.save()
        pyotherside.send('podcast-list-changed')
        pyotherside.send('update-stats')
        # TODO: Return True/False for reporting success

    def rename_podcast(self, podcast_id, new_title):
        podcast = self._get_podcast_by_id(podcast_id)
        podcast.rename(new_title)
        self.core.save()
        pyotherside.send('podcast-list-changed')

    def change_section(self, podcast_id, new_section):
        podcast = self._get_podcast_by_id(podcast_id)
        podcast.section = new_section
        podcast.save()
        self.core.save()
        pyotherside.send('podcast-list-changed')

    @run_in_background_thread
    def unsubscribe(self, podcast_id):
        podcast = self._get_podcast_by_id(podcast_id)
        podcast.unsubscribe()
        self.core.save()
        pyotherside.send('podcast-list-changed')
        pyotherside.send('update-stats')

    @run_in_background_thread
    def download_episode(self, episode_id):
        def progress_callback(progress):
            pyotherside.send('download-progress', episode_id, progress)
        episode = self._get_episode_by_id(episode_id)
        if episode.state == gpodder.STATE_DOWNLOADED:
            return

        pyotherside.send('downloading', episode_id)
        if episode.download(progress_callback):
            pyotherside.send('downloaded', episode_id)
        else:
            pyotherside.send('download-failed', episode_id)
        self.core.save()
        pyotherside.send('update-stats')

    @run_in_background_thread
    def delete_episode(self, episode_id):
        episode = self._get_episode_by_id(episode_id)
        episode.delete()
        pyotherside.send('deleted', episode_id)
        pyotherside.send('update-stats')

    @run_in_background_thread
    def toggle_new(self, episode_id):
        episode = self._get_episode_by_id(episode_id)
        episode.is_new = not episode.is_new
        if episode.is_new and episode.state == gpodder.STATE_DELETED:
            episode.state = gpodder.STATE_NORMAL
        episode.save()
        self.core.save()
        pyotherside.send('is-new-changed', episode_id, episode.is_new)
        pyotherside.send('state-changed', episode_id, episode.state)

    @run_in_background_thread
    def check_for_episodes(self):
        if self._checking_for_new_episodes:
            return

        self._checking_for_new_episodes = True
        pyotherside.send('refreshing', True)
        podcasts = self._get_podcasts_sorted()
        for index, podcast in enumerate(podcasts):
            pyotherside.send('refresh-progress', index, len(podcasts))
            pyotherside.send('updating-podcast', podcast.id)
            try:
                podcast.update()
            except Exception as e:
                logger.warn('Could not update %s: %s', podcast.url,
                        e, exc_info=True)
            pyotherside.send('updated-podcast', self.convert_podcast(podcast))
            pyotherside.send('update-stats')

        self.core.save()
        self._checking_for_new_episodes = False
        pyotherside.send('refreshing', False)

    def play_episode(self, episode_id):
        episode = self._get_episode_by_id(episode_id)
        episode.playback_mark()
        self.core.save()
        pyotherside.send('is-new-changed', episode_id, episode.is_new)
        return {
            'title': episode.title,
            'podcast_title': episode.parent.title,
            'source': episode.local_filename(False)
                if episode.state == gpodder.STATE_DOWNLOADED
                else episode.url,
            'position': episode.current_position,
            'total': episode.total_time,
            'video': episode.file_type() == 'video',
        }

    def report_playback_event(self, episode_id, position_from, position_to, duration):
        episode = self._get_episode_by_id(episode_id)
        print('Played', episode.title, 'from', position_from, 'to', position_to, 'of', duration)
        episode.report_playback_event(position_from, position_to, duration)
        pyotherside.send('playback-progress', episode_id, self._get_playback_progress(episode))

    def show_episode(self, episode_id):
        episode = self._get_episode_by_id(episode_id)
        if episode is None:
            return {}

        return {
            'title': episode.trimmed_title,
            'description': util.remove_html_tags(episode.description),
        }

gpotherside = gPotherSide()
pyotherside.atexit(gpotherside.atexit)

pyotherside.send('hello', gpodder.__version__, gpodder.__copyright__)

# Exposed API Endpoints for calls from QML
initialize = gpotherside.initialize
load_podcasts = gpotherside.load_podcasts
load_episodes = gpotherside.load_episodes
show_episode = gpotherside.show_episode
play_episode = gpotherside.play_episode
subscribe = gpotherside.subscribe
unsubscribe = gpotherside.unsubscribe
check_for_episodes = gpotherside.check_for_episodes
get_stats = gpotherside.get_stats
get_fresh_episodes = gpotherside.get_fresh_episodes
get_fresh_episodes_summary = gpotherside.get_fresh_episodes_summary
download_episode = gpotherside.download_episode
delete_episode = gpotherside.delete_episode
toggle_new = gpotherside.toggle_new
rename_podcast = gpotherside.rename_podcast
change_section = gpotherside.change_section
report_playback_event = gpotherside.report_playback_event
