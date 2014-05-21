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

# Version of the QML UI implementation, this is usually the same as the version
# of gpodder-core, but we might have a different release schedule later on. If
# we decide to have parallel releases, we can at least start using this version
# to check if the core version is compatible with the QML UI version.
__version__ = '4.2.0'

import sys
import os

sys.path.insert(0, os.path.join(os.path.dirname(__file__), '..', 'gpodder-core', 'src'))

import pyotherside
import gpodder

from gpodder.api import core
from gpodder.api import util
from gpodder.api import query

import logging
import functools
import time
import datetime

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
    ALL_PODCASTS = -1

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

    def _episode_state_changed(self, episode):
        pyotherside.send('updated-episode', self.convert_episode(episode))
        pyotherside.send('updated-podcast', self.convert_podcast(episode.parent))
        pyotherside.send('update-stats')

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

        return {
            'podcasts': len(podcasts),
            'episodes': total,
            'newEpisodes': new,
            'downloaded': downloaded,
        }

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
        sort_key = self.core.model.podcast_sort_key
        return sorted(self.core.model.get_podcasts(),
                key=lambda podcast: (podcast.section, sort_key(podcast)))

    def load_podcasts(self):
        podcasts = self._get_podcasts_sorted()
        return [self.convert_podcast(podcast) for podcast in podcasts]

    def convert_episode(self, episode):
        now = datetime.datetime.now()
        tnow = time.time()
        return {
            'id': episode.id,
            'title': episode.trimmed_title,
            'progress': episode.download_progress(),
            'downloadState': episode.state,
            'isNew': episode.is_new,
            'playbackProgress': self._get_playback_progress(episode),
            'published': util.format_date(episode.published),
            'section': self._format_published_section(now, tnow, episode.published),
            'hasShownotes': episode.description != '',
        }

    def _format_published_section(self, now, tnow, published):
        diff = (tnow - published)

        if diff < 60 * 60 * 24 * 7:
            return util.format_date(published)

        dt = datetime.datetime.fromtimestamp(published)
        if dt.year == now.year:
            return dt.strftime('%B %Y')

        return dt.strftime('%Y')

    def load_episodes(self, id=ALL_PODCASTS, eql=None):
        if id is not None and id != self.ALL_PODCASTS:
            podcasts = [self._get_podcast_by_id(id)]
        else:
            podcasts = self.core.model.get_podcasts()

        if eql:
            filter_func = query.EQL(eql).filter
        else:
            filter_func = lambda episodes: episodes

        result = []

        for podcast in podcasts:
            result.extend(filter_func(podcast.episodes))

        if id == self.ALL_PODCASTS:
            result.sort(key=lambda e: e.published, reverse=True)

        return [self.convert_episode(episode) for episode in result]

    def get_fresh_episodes_summary(self, count):
        summary = []
        for podcast in self.core.model.get_podcasts():
            _, _, new, _, _ = podcast.get_statistics()
            if new:
                summary.append({
                    'title': podcast.title,
                    'coverart': self._get_cover(podcast),
                    'newEpisodes': new,
                })

        summary.sort(key=lambda e: e['newEpisodes'], reverse=True)
        return summary[:int(count)]

    @run_in_background_thread
    def subscribe(self, url):
        url = self.core.model.normalize_feed_url(url)
        # TODO: Check if subscription already exists

        # Kludge: After one second, update the podcast list,
        # so that we see the podcast that is being updated
        @run_in_background_thread
        def show_loading():
            time.sleep(1)
            pyotherside.send('podcast-list-changed')
        show_loading()

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

    def unsubscribe(self, podcast_id):
        podcast = self._get_podcast_by_id(podcast_id)
        podcast.unsubscribe()
        self.core.save()
        pyotherside.send('podcast-list-changed')
        pyotherside.send('update-stats')

    @run_in_background_thread
    def download_episode(self, episode_id):
        episode = self._get_episode_by_id(episode_id)
        if episode.state == gpodder.STATE_DOWNLOADED:
            return

        def progress_callback(progress):
            self._episode_state_changed(episode)

        # TODO: Handle the case where there is already a DownloadTask
        episode.download(progress_callback)
        self.core.save()
        self._episode_state_changed(episode)

    def delete_episode(self, episode_id):
        episode = self._get_episode_by_id(episode_id)
        episode.delete()
        self.core.save()
        self._episode_state_changed(episode)

    def toggle_new(self, episode_id):
        episode = self._get_episode_by_id(episode_id)
        episode.is_new = not episode.is_new
        if episode.is_new and episode.state == gpodder.STATE_DELETED:
            episode.state = gpodder.STATE_NORMAL
        episode.save()
        self.core.save()
        self._episode_state_changed(episode)

    def mark_episodes_as_old(self, podcast_id):
        podcast = self._get_podcast_by_id(podcast_id)

        any_changed = False
        for episode in podcast.episodes:
            if episode.is_new and episode.state == gpodder.STATE_NORMAL:
                any_changed = True
                episode.is_new = False
                episode.save()

        if any_changed:
            pyotherside.send('episode-list-changed', podcast_id)
            pyotherside.send('updated-podcast', self.convert_podcast(podcast))
            pyotherside.send('update-stats')

        self.core.save()

    def save_playback_state(self):
        self.core.save()

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
        self._episode_state_changed(episode)
        return {
            'title': episode.title,
            'podcast_title': episode.parent.title,
            'source': episode.local_filename(False)
                if episode.state == gpodder.STATE_DOWNLOADED
                else episode.url,
            'position': episode.current_position,
            'total': episode.total_time,
            'video': episode.file_type() == 'video',
            'chapters': getattr(episode, 'chapters', []),
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
            'metadata': ' | '.join(self._format_metadata(episode)),
            'link': episode.link if episode.link != episode.url else '',
            'chapters': getattr(episode, 'chapters', []),
        }

    def _format_metadata(self, episode):
        if episode.published:
            yield datetime.datetime.fromtimestamp(episode.published).strftime('%Y-%m-%d')

        if episode.file_size > 0:
            yield '%.2f MiB' % (episode.file_size / (1024 * 1024))

        if episode.total_time > 0:
            yield '%02d:%02d:%02d' % (episode.total_time / (60 * 60), (episode.total_time / 60) % 60, episode.total_time % 60)

gpotherside = gPotherSide()
pyotherside.atexit(gpotherside.atexit)

pyotherside.send('hello', gpodder.__version__, __version__)

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
get_fresh_episodes_summary = gpotherside.get_fresh_episodes_summary
download_episode = gpotherside.download_episode
delete_episode = gpotherside.delete_episode
toggle_new = gpotherside.toggle_new
rename_podcast = gpotherside.rename_podcast
change_section = gpotherside.change_section
report_playback_event = gpotherside.report_playback_event
mark_episodes_as_old = gpotherside.mark_episodes_as_old
save_playback_state = gpotherside.save_playback_state
