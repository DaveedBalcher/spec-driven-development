/* 3 Days of Spec-Driven Development — the only script.
   No dependencies, no build step, no network requests of its own. Loaded from
   <head> without defer so the theme and lane are set before the body paints;
   everything that touches the DOM waits for DOMContentLoaded.

   Every page is complete with this file missing or JavaScript off. What the
   script adds: theme memory, lane memory, Day 3 track tabs, progress ticks,
   the video embed swap, per-team wording, and a Copy button on bash blocks.

   Markup contracts
   ----------------
   Theme     <button data-theme-toggle hidden>Dark</button>
   Lane      <div class="lane" hidden>
               <button data-lane-set="swift">Swift</button>
               <button data-lane-set="kotlin">Kotlin</button></div>
             Content: <div class="lane-block lane-swift"> … </div>
             Until the reader picks a lane — and with the script off — both lane
             blocks show, each with its name. Nothing is hidden before a choice.
   Tracks    <div class="tabs" data-show-all="true">
               <div role="tablist" aria-label="Framework track" hidden>
                 <button role="tab" data-track="openspec" id="tab-openspec"
                         aria-controls="panel-openspec">OpenSpec</button> … </div>
               <button data-show-all-toggle hidden>Show all three</button>
               <section class="tab-panel" role="tabpanel" data-track="openspec"
                        id="panel-openspec" aria-labelledby="tab-openspec"> … </section></div>
             Each tab carries aria-controls naming its panel; the script sets it
             again from the matching panel id if the markup left it out.
             Panels are visible in the markup; the script hides the inactive
             ones once the tablist is live. ?track=openspec|lid|bmad deep-links.
   Progress  <input type="checkbox" data-progress="d1-l3-read" id="…">
             Stored under sdd.progress.<day>, or sdd.progress.<day>.<track>
             when the checkbox sits inside a [data-track] panel.
   Video     <div class="video" data-video-id="…" data-start="0" data-end="191"
                  data-video-title="Title (channel, date)"> … plain link … </div>
             The Play panel is drawn locally; nothing leaves this origin until
             the reader clicks it and the youtube-nocookie iframe is created.
   Wording   <span data-env="sourceConnector">generic fallback text</span>
   Copy      <pre data-lang="bash"><code> … </code></pre>
             The script wraps each one in <div class="code-copy"> and adds a
             Copy button that puts the block's text on the clipboard.

   Storage keys: sdd.theme, sdd.lane, sdd.track, sdd.progress.<day>[.<track>].
   Every read and write is wrapped; when the browser refuses (Safari over
   file://, private windows, blocked site data) the same values live in memory
   for the session and the page keeps working. */

(function () {
  'use strict';

  var THEME_KEY = 'sdd.theme';
  var LANE_KEY = 'sdd.lane';
  var TRACK_KEY = 'sdd.track';
  var PROGRESS_PREFIX = 'sdd.progress.';
  var LANES = ['swift', 'kotlin'];
  var TRACKS = ['openspec', 'lid', 'bmad'];
  var root = document.documentElement;

  /* ---------- storage: localStorage when it works, memory when it does not ---------- */

  var memory = {};
  var storageWorks = null;

  function store() {
    if (storageWorks === null) {
      try {
        window.localStorage.setItem('sdd.probe', '1');
        window.localStorage.removeItem('sdd.probe');
        storageWorks = true;
      } catch (e) {
        storageWorks = false;
      }
    }
    return storageWorks ? window.localStorage : null;
  }

  function read(key) {
    var s = store();
    if (s) {
      try {
        var v = s.getItem(key);
        if (v !== null) { return v; }
      } catch (e) { /* fall through to memory */ }
    }
    return Object.prototype.hasOwnProperty.call(memory, key) ? memory[key] : null;
  }

  function write(key, value) {
    memory[key] = value;
    var s = store();
    if (s) {
      try { s.setItem(key, value); } catch (e) { /* memory already holds it */ }
    }
  }

  function keysWithPrefix(prefix) {
    var out = [];
    var i;
    var s = store();
    if (s) {
      try {
        for (i = 0; i < s.length; i++) {
          var k = s.key(i);
          if (k && k.indexOf(prefix) === 0 && out.indexOf(k) < 0) { out.push(k); }
        }
      } catch (e) { /* fall through to memory */ }
    }
    for (var m in memory) {
      if (Object.prototype.hasOwnProperty.call(memory, m) && m.indexOf(prefix) === 0 && out.indexOf(m) < 0) {
        out.push(m);
      }
    }
    out.sort();
    return out;
  }

  function readObject(key) {
    var raw = read(key);
    if (!raw) { return {}; }
    try {
      var parsed = JSON.parse(raw);
      return (parsed && typeof parsed === 'object' && !(parsed instanceof Array)) ? parsed : {};
    } catch (e) {
      return {};
    }
  }

  function writeObject(key, value) {
    try { write(key, JSON.stringify(value)); } catch (e) { /* nothing more to do */ }
  }

  /* ---------- small helpers ---------- */

  function all(selector, context) {
    return Array.prototype.slice.call((context || document).querySelectorAll(selector));
  }

  function ready(fn) {
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', fn);
    } else {
      fn();
    }
  }

  function queryParam(name) {
    var search = window.location.search || '';
    var match = new RegExp('[?&]' + name + '=([^&#]*)').exec(search);
    if (!match) { return null; }
    try { return decodeURIComponent(match[1].replace(/\+/g, ' ')); } catch (e) { return match[1]; }
  }

  function pageDay() {
    var meta = document.querySelector('meta[name="course:day"]');
    var value = meta ? (meta.getAttribute('content') || '').trim() : '';
    return value === '' ? '0' : value;
  }

  /* ---------- theme and lane: applied before the body paints ---------- */

  var storedTheme = read(THEME_KEY);
  if (storedTheme === 'dark' || storedTheme === 'light') {
    root.setAttribute('data-theme', storedTheme);
  }

  var lane = read(LANE_KEY);
  if (LANES.indexOf(lane) < 0) { lane = null; }
  /* No default: with no stored choice the attribute stays off and both lane
     blocks render, which is what the setup page promises. */
  if (lane) { root.setAttribute('data-lane', lane); }

  var track = queryParam('track');
  if (TRACKS.indexOf(track) > -1) {
    write(TRACK_KEY, track);          /* a deep link sets the track for later pages too */
  } else {
    track = read(TRACK_KEY);
    if (TRACKS.indexOf(track) < 0) { track = TRACKS[0]; }
  }

  function effectiveTheme() {
    var explicit = root.getAttribute('data-theme');
    if (explicit === 'dark' || explicit === 'light') { return explicit; }
    var dark = false;
    try {
      dark = !!(window.matchMedia && window.matchMedia('(prefers-color-scheme: dark)').matches);
    } catch (e) { dark = false; }
    return dark ? 'dark' : 'light';
  }

  function initTheme() {
    var buttons = all('[data-theme-toggle]');
    if (!buttons.length) { return; }

    function paint() {
      var now = effectiveTheme();
      var next = now === 'dark' ? 'light' : 'dark';
      buttons.forEach(function (button) {
        button.hidden = false;
        button.textContent = next === 'dark' ? 'Dark' : 'Light';
        button.setAttribute('aria-label', 'Switch to the ' + next + ' theme');
        button.setAttribute('title', 'Switch to the ' + next + ' theme');
      });
    }

    buttons.forEach(function (button) {
      button.addEventListener('click', function () {
        var next = effectiveTheme() === 'dark' ? 'light' : 'dark';
        root.setAttribute('data-theme', next);
        write(THEME_KEY, next);
        paint();
      });
    });
    paint();
  }

  function initLane() {
    var groups = all('.lane');
    var buttons = all('[data-lane-set]');
    if (!buttons.length) { return; }

    function paint() {
      buttons.forEach(function (button) {
        var value = button.getAttribute('data-lane-set');
        button.setAttribute('aria-pressed', value === lane ? 'true' : 'false');
      });
    }

    groups.forEach(function (group) { group.hidden = false; });
    buttons.forEach(function (button) {
      button.addEventListener('click', function () {
        var value = button.getAttribute('data-lane-set');
        if (LANES.indexOf(value) < 0) { return; }
        lane = value;
        root.setAttribute('data-lane', lane);
        write(LANE_KEY, lane);
        paint();
      });
    });
    paint();
  }

  /* ---------- Day 3 track tabs ---------- */

  function initTracks() {
    all('.tabs').forEach(function (group) {
      var tablist = group.querySelector('[role="tablist"]');
      var tabs = all('[role="tab"][data-track]', group);
      var panels = all('[role="tabpanel"][data-track]', group);
      if (!tablist || !tabs.length || !panels.length) { return; }

      var showAllToggle = group.hasAttribute('data-show-all')
        ? group.querySelector('[data-show-all-toggle]')
        : null;
      var showingAll = false;

      tablist.hidden = false;

      function panelFor(value) {
        return panels.filter(function (panel) {
          return panel.getAttribute('data-track') === value;
        })[0] || null;
      }

      function paint() {
        tabs.forEach(function (tab) {
          var value = tab.getAttribute('data-track');
          var selected = !showingAll && value === track;
          tab.setAttribute('aria-selected', selected ? 'true' : 'false');
          tab.setAttribute('tabindex', selected ? '0' : '-1');
          if (!tab.getAttribute('aria-controls')) {
            var panel = panelFor(value);
            if (panel && panel.id) { tab.setAttribute('aria-controls', panel.id); }
          }
        });
        if (showingAll && tabs.length) { tabs[0].setAttribute('tabindex', '0'); }
        panels.forEach(function (panel) {
          panel.hidden = !showingAll && panel.getAttribute('data-track') !== track;
        });
        group.classList.toggle('tabs-all', showingAll);
        if (showAllToggle) {
          showAllToggle.setAttribute('aria-pressed', showingAll ? 'true' : 'false');
          showAllToggle.textContent = showingAll ? 'Show one track' : 'Show all three';
        }
      }

      function select(value, focus) {
        if (TRACKS.indexOf(value) < 0) { return; }
        track = value;
        write(TRACK_KEY, track);
        showingAll = false;
        paint();
        if (focus) {
          var target = tabs.filter(function (tab) { return tab.getAttribute('data-track') === track; })[0];
          if (target) { target.focus(); }
        }
        document.dispatchEvent(new CustomEvent('sdd:track', { detail: { track: track } }));
      }

      tabs.forEach(function (tab, index) {
        tab.addEventListener('click', function () { select(tab.getAttribute('data-track'), false); });
        tab.addEventListener('keydown', function (event) {
          var key = event.key;
          var next = null;
          if (key === 'ArrowRight' || key === 'ArrowDown') { next = (index + 1) % tabs.length; }
          else if (key === 'ArrowLeft' || key === 'ArrowUp') { next = (index - 1 + tabs.length) % tabs.length; }
          else if (key === 'Home') { next = 0; }
          else if (key === 'End') { next = tabs.length - 1; }
          if (next === null) { return; }
          event.preventDefault();
          select(tabs[next].getAttribute('data-track'), true);
        });
      });

      if (showAllToggle) {
        showAllToggle.hidden = false;
        showAllToggle.addEventListener('click', function () {
          showingAll = !showingAll;
          paint();
        });
      }

      paint();
    });
  }

  /* ---------- progress ---------- */

  function progressKey(input) {
    var panel = input.closest ? input.closest('[data-track]') : null;
    var suffix = panel ? '.' + panel.getAttribute('data-track') : '';
    return PROGRESS_PREFIX + pageDay() + suffix;
  }

  function applyStoredProgress() {
    all('input[type="checkbox"][data-progress]').forEach(function (input) {
      var state = readObject(progressKey(input));
      input.checked = state[input.getAttribute('data-progress')] === true;
    });
  }

  function countChecked(day) {
    var total = 0;
    var base = PROGRESS_PREFIX + day;
    keysWithPrefix(base).forEach(function (key) {
      var rest = key.slice(base.length);
      if (rest !== '' && rest.charAt(0) !== '.') { return; }
      /* A day with tracks holds one key per track. Count the chosen track only,
         so sampling all three does not treble that day's total. */
      if (rest !== '' && rest.slice(1) !== track) { return; }
      var state = readObject(key);
      for (var id in state) {
        if (Object.prototype.hasOwnProperty.call(state, id) && state[id] === true) { total++; }
      }
    });
    return total;
  }

  function paintSummary() {
    all('[data-progress-day]').forEach(function (row) {
      var slot = row.querySelector('[data-progress-value]');
      if (!slot) { return; }
      var day = row.getAttribute('data-progress-day');
      var done = countChecked(day);
      var total = (row.getAttribute('data-progress-total') || '').trim();
      slot.textContent = total ? done + ' of ' + total + ' done' : done + ' ticked';
    });
    var note = document.querySelector('[data-progress-note]');
    if (note) {
      var canTransfer = !!document.querySelector('[data-progress-transfer]');
      note.hidden = false;
      if (storageWorks === false) {
        note.textContent = 'This browser is not storing progress, so ticks last until you leave the page. Everything else works.';
      } else {
        /* Only the page carrying the transfer box may point at it. */
        note.textContent = canTransfer
          ? 'Progress is stored in this browser only. Copy it below to move it to another browser.'
          : 'Progress is stored in this browser only.';
      }
    }
  }

  function initProgress() {
    var inputs = all('input[type="checkbox"][data-progress]');
    applyStoredProgress();

    inputs.forEach(function (input) {
      input.addEventListener('change', function () {
        var key = progressKey(input);
        var state = readObject(key);
        var id = input.getAttribute('data-progress');
        if (input.checked) { state[id] = true; } else { delete state[id]; }
        writeObject(key, state);
        paintSummary();
      });
    });

    var transfer = document.querySelector('[data-progress-transfer]');
    var status = document.querySelector('[data-progress-status]');
    var tools = all('[data-progress-action]');

    function say(message) {
      if (status) { status.hidden = false; status.textContent = message; }
    }

    /* The box ships hidden, and so does its label; they appear together. */
    function showTransfer() {
      if (!transfer) { return; }
      transfer.hidden = false;
      if (transfer.id) {
        all('label[for="' + transfer.id + '"]').forEach(function (label) { label.hidden = false; });
      }
    }

    tools.forEach(function (button) {
      button.hidden = false;
      button.addEventListener('click', function () {
        var action = button.getAttribute('data-progress-action');

        if (action === 'copy') {
          var bundle = {};
          keysWithPrefix(PROGRESS_PREFIX).forEach(function (key) { bundle[key] = readObject(key); });
          var text = JSON.stringify(bundle, null, 2);
          if (transfer) { showTransfer(); transfer.value = text; transfer.select(); }
          if (navigator.clipboard && navigator.clipboard.writeText) {
            navigator.clipboard.writeText(text).then(function () {
              say('Progress copied to the clipboard, and printed in the box below.');
            }, function () {
              say('Copy the text in the box below by hand; this browser blocked the clipboard.');
            });
          } else {
            say('Copy the text in the box below by hand; this browser has no clipboard access.');
          }
          return;
        }

        if (action === 'paste') {
          if (!transfer) { return; }
          showTransfer();
          var raw = (transfer.value || '').trim();
          if (!raw) { transfer.focus(); say('Paste your progress into the box, then press Load progress.'); return; }
          var incoming;
          try { incoming = JSON.parse(raw); } catch (e) { incoming = null; }
          if (!incoming || typeof incoming !== 'object' || incoming instanceof Array) {
            say('That is not progress JSON. Press Copy progress in the other browser and paste all of it.');
            return;
          }
          var loaded = 0;
          for (var key in incoming) {
            if (!Object.prototype.hasOwnProperty.call(incoming, key)) { continue; }
            if (key.indexOf(PROGRESS_PREFIX) !== 0) { continue; }
            var value = incoming[key];
            if (!value || typeof value !== 'object' || value instanceof Array) { continue; }
            var clean = {};
            for (var id in value) {
              if (Object.prototype.hasOwnProperty.call(value, id) && value[id] === true) { clean[id] = true; loaded++; }
            }
            writeObject(key, clean);
          }
          applyStoredProgress();
          paintSummary();
          say(loaded + ' ticked ' + (loaded === 1 ? 'item' : 'items') + ' loaded into this browser.');
          return;
        }
      });
    });

    paintSummary();
  }

  /* ---------- video cards ---------- */

  function initVideos() {
    all('.video[data-video-id]').forEach(function (card) {
      var id = card.getAttribute('data-video-id');
      if (!id || id === 'VIDEO_ID') { return; }

      var title = card.getAttribute('data-video-title') || 'Course video';
      var start = parseInt(card.getAttribute('data-start') || '0', 10);
      var end = parseInt(card.getAttribute('data-end') || '0', 10);
      if (isNaN(start) || start < 0) { start = 0; }

      var button = document.createElement('button');
      button.type = 'button';
      button.className = 'video-thumb';
      button.setAttribute('aria-label', 'Play ' + title + ' here');

      /* A local panel, not a remote thumbnail: the first request to any other
         origin is the iframe below, created on the click. */
      var play = document.createElement('span');
      play.className = 'video-play';
      play.textContent = 'Play';

      button.appendChild(play);

      button.addEventListener('click', function () {
        var src = 'https://www.youtube-nocookie.com/embed/' + id + '?start=' + start;
        if (!isNaN(end) && end > start) { src += '&end=' + end; }
        src += '&autoplay=1';

        var frame = document.createElement('div');
        frame.className = 'video-frame';
        var iframe = document.createElement('iframe');
        iframe.src = src;
        iframe.title = title;
        /* Fullscreen comes from allowfullscreen alone: naming it in allow as
           well makes Chrome log a warning on every Play. */
        iframe.setAttribute('allow', 'autoplay; encrypted-media; picture-in-picture');
        iframe.setAttribute('allowfullscreen', '');
        iframe.setAttribute('referrerpolicy', 'strict-origin-when-cross-origin');
        frame.appendChild(iframe);
        button.parentNode.replaceChild(frame, button);
        iframe.focus();
      });

      card.appendChild(button);
    });
  }

  /* ---------- per-team wording ---------- */

  function initEnv() {
    var profile = window.ENV_PROFILE;
    if (!profile || typeof profile !== 'object') { return; }
    all('[data-env]').forEach(function (node) {
      var key = node.getAttribute('data-env');
      var value = profile[key];
      if (typeof value === 'string' && value.trim() !== '') {
        node.textContent = value;
      }
    });
  }

  /* ---------- copy button on bash blocks ---------- */

  function copyText(text) {
    if (navigator.clipboard && navigator.clipboard.writeText) {
      return navigator.clipboard.writeText(text);
    }
    // No async clipboard (an insecure origin, an older browser): select and copy.
    return new Promise(function (resolve, reject) {
      var area = document.createElement('textarea');
      area.value = text;
      area.setAttribute('readonly', '');
      area.style.position = 'fixed';
      area.style.opacity = '0';
      document.body.appendChild(area);
      area.select();
      var ok = false;
      try { ok = document.execCommand('copy'); } catch (e) { ok = false; }
      document.body.removeChild(area);
      if (ok) { resolve(); } else { reject(); }
    });
  }

  // The button sits in a wrapper, not in the <pre>, so it stays put when a
  // wide block scrolls sideways and is never part of the copied text.
  function initCopyButtons() {
    all('pre[data-lang="bash"]').forEach(function (pre) {
      var wrap = document.createElement('div');
      wrap.className = 'code-copy';
      pre.parentNode.insertBefore(wrap, pre);
      wrap.appendChild(pre);

      var button = document.createElement('button');
      button.type = 'button';
      button.className = 'copy-button';
      button.textContent = 'Copy';
      button.setAttribute('aria-label', 'Copy this command');
      var timer = null;
      function say(label) {
        button.textContent = label;
        if (timer) { clearTimeout(timer); }
        timer = setTimeout(function () { button.textContent = 'Copy'; }, 1600);
      }
      button.addEventListener('click', function () {
        var code = pre.querySelector('code') || pre;
        copyText(code.textContent.replace(/\n+$/, '')).then(function () {
          say('Copied');
        }, function () {
          say('Blocked');
        });
      });
      wrap.appendChild(button);
    });
  }

  /* ---------- keyboard scroll for wide code ---------- */

  // Keyboard users cannot scroll an overflowing <pre> unless it can take focus.
  // Runs after parse, and again whenever a hidden block can become visible:
  // a <details> opening, a lane or track switch, a resize.
  function initPreTabStops() {
    function mark() {
      all('pre').forEach(function (pre) {
        if (pre.scrollWidth > pre.clientWidth && !pre.hasAttribute('tabindex')) {
          pre.setAttribute('tabindex', '0');
        }
      });
    }
    var timer = null;
    mark();
    function later() {
      if (timer) { clearTimeout(timer); }
      timer = setTimeout(mark, 150);
    }
    document.addEventListener('toggle', mark, true);
    window.addEventListener('resize', later);
    // A lane or track switch shows blocks that were hidden, and hidden blocks report no overflow.
    all('[data-lane-set], [data-track]').forEach(function (control) {
      control.addEventListener('click', later);
    });
  }

  ready(function () {
    initTheme();
    initLane();
    initTracks();
    initProgress();
    initVideos();
    initEnv();
    initCopyButtons();
    initPreTabStops();
  });
}());
