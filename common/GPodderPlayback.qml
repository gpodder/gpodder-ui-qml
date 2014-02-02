
/**
 *
 * gPodder QML UI Reference Implementation
 * Copyright (c) 2013, 2014, Thomas Perl <m@thp.io>
 *
 * Permission to use, copy, modify, and/or distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES WITH
 * REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY SPECIAL, DIRECT,
 * INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM
 * LOSS OF USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
 * OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
 * PERFORMANCE OF THIS SOFTWARE.
 *
 */

import QtQuick 2.0
import QtMultimedia 5.0

MediaPlayer {
    id: player

    property int episode: 0
    property var queue: ([])
    property bool isPlaying: playbackState == MediaPlayer.PlayingState

    property bool inhibitPositionEvents: false
    property bool seekAfterPlay: false
    property int seekTargetSeconds: 0
    property int lastPosition: 0
    property int lastDuration: 0
    property int playedFrom: 0

    function playbackEpisode(episode_id) {
        if (episode == episode_id) {
            // If the episode is already loaded, just start playing
            play();
            return;
        }

        // First, make sure we stop any seeking / position update events
        sendPositionToCore(lastPosition);
        player.inhibitPositionEvents = true;
        player.stop();

        py.call('main.play_episode', [episode_id], function (episode) {
            // Load media / prepare and start playback
            player.episode = episode_id;
            player.source = episode.source;
            player.seekTargetSeconds = episode.position;
            seekAfterPlay = true;

            player.play();
        });
    }

    function seekAndSync(target_position) {
        sendPositionToCore(lastPosition);
        seek(target_position);
        playedFrom = target_position;
    }

    onPlaybackStateChanged: {
        if (playbackState == MediaPlayer.PlayingState) {
            if (seekAfterPlay) {
                // A seek was scheduled, execute now that we're playing
                player.inhibitPositionEvents = false;
                player.seek(seekTargetSeconds * 1000);
                player.playedFrom = seekTargetSeconds * 1000;
                seekAfterPlay = false;
            } else {
                player.playedFrom = position;
            }
        } else {
            sendPositionToCore(lastPosition);
        }
    }

    function sendPositionToCore(positionToSend) {
        if (episode != 0 && !inhibitPositionEvents) {
            var begin = playedFrom / 1000;
            var end = positionToSend / 1000;
            var duration = ((lastDuration > 0) ? lastDuration : 0) / 1000;
            var diff = end - begin;

            // Only send playback events if they are 2 seconds or longer
            // (all other events might just be seeking events or wrong ones)
            if (diff >= 2) {
                py.call('main.report_playback_event', [episode, begin, end, duration]);
            }
        }
    }

    onPositionChanged: {
        if (isPlaying && !inhibitPositionEvents) {
            lastPosition = position;
            lastDuration = duration;

            // Directly update the playback progress in the episode list
            py.playbackProgress(episode, position / duration);
        }
    }
}
