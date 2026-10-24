// Passes reserved keys (Super, Alt+Tab, Esc, ...) through to the remote session. The lock only
// applies in fullscreen requested by the page (not F11), so Ctrl+Shift+F toggles that.
// While locked, hold Esc to leave fullscreen.
//   chromium: Keyboard Lock API (navigator.keyboard.lock)
//   firefox:  requestFullscreen({ keyboardLock }), needs dom.fullscreen.keyboard_lock.enabled.
//             only "browser" mode exists (Ctrl+W/T/Tab, Esc...), OS keys like Super/Alt+Tab
//             still go to the local system
(function () {
    var chromiumLock = navigator.keyboard && navigator.keyboard.lock;

    if (chromiumLock) {
        document.addEventListener('fullscreenchange', function () {
            if (document.fullscreenElement)
                navigator.keyboard.lock();
            else
                navigator.keyboard.unlock();
        });
    }

    window.addEventListener('keydown', function (e) {
        if (e.code !== 'KeyF' || !e.ctrlKey || !e.shiftKey || e.altKey || e.metaKey)
            return;

        e.preventDefault();
        e.stopImmediatePropagation();

        if (document.fullscreenElement)
            document.exitFullscreen();
        else
            // browsers without the option ignore it
            document.documentElement.requestFullscreen({ keyboardLock: 'browser' });
    }, true);
})();
