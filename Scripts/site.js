/* Baked With Love - client-side behaviour (plain ECMAScript, no libraries) */
// Each function below adds one feature. They all run once the page has loaded (see the bottom).

// Mobile hamburger menu
function initMenu() {
    var toggle = document.getElementById("menuToggle");
    var menu = document.getElementById("mobileMenu");
    if (!toggle || !menu) return;
    toggle.addEventListener("click", function () {
        var open = menu.classList.toggle("open");
        toggle.setAttribute("aria-expanded", open ? "true" : "false");
    });
}

// Countdown timers: <div class="countdown" data-until="2026-11-09T18:00:00">
function initCountdowns() {
    var timers = document.querySelectorAll("[data-until]");
    if (!timers.length) return;
    function pad(n) { return (n < 10 ? "0" : "") + n; }
    function tick() {
        for (var i = 0; i < timers.length; i++) {
            var el = timers[i];
            var left = new Date(el.getAttribute("data-until")).getTime() - Date.now();
            if (left <= 0) { el.innerHTML = "<span>Closed for today</span>"; continue; }
            var h = Math.floor(left / 3600000), m = Math.floor(left / 60000) % 60, s = Math.floor(left / 1000) % 60;
            el.innerHTML = "<span>" + pad(h) + "<small>hrs</small></span><span>" + pad(m) +
                "<small>min</small></span><span>" + pad(s) + "<small>sec</small></span>";
        }
    }
    tick();
    setInterval(tick, 1000);
}

// Image preview for file uploads: <input type="file" data-preview="imgId">
function initUploadPreview() {
    var inputs = document.querySelectorAll("input[type=file][data-preview]");
    for (var i = 0; i < inputs.length; i++) {
        inputs[i].addEventListener("change", function () {
            var img = document.getElementById(this.getAttribute("data-preview"));
            if (!img || !this.files || !this.files[0]) return;
            if (this.files[0].size > 4 * 1024 * 1024) {
                alert("Please choose an image smaller than 4 MB.");
                this.value = "";
                return;
            }
            var reader = new FileReader();
            reader.onload = function (e) { img.src = e.target.result; img.classList.remove("hidden"); };
            reader.readAsDataURL(this.files[0]);
        });
    }
}

// Animate bar charts and progress bars once the page has loaded
function initBars() {
    var bars = document.querySelectorAll("[data-height], [data-width]");
    setTimeout(function () {
        for (var i = 0; i < bars.length; i++) {
            if (bars[i].getAttribute("data-height")) bars[i].style.height = bars[i].getAttribute("data-height");
            if (bars[i].getAttribute("data-width")) bars[i].style.width = bars[i].getAttribute("data-width");
        }
    }, 120);
}

// Show / hide sections based on a radio button: <div data-show-when="radioName=value">
function initConditional() {
    var blocks = document.querySelectorAll("[data-show-when]");
    if (!blocks.length) return;
    function update() {
        for (var i = 0; i < blocks.length; i++) {
            var rule = blocks[i].getAttribute("data-show-when").split("=");
            var checked = document.querySelector("input[name$='" + rule[0] + "']:checked");
            var match = checked && checked.value === rule[1];
            blocks[i].classList.toggle("hidden", !match);
        }
    }
    document.addEventListener("change", update);
    update();
}

document.addEventListener("DOMContentLoaded", function () {
    initMenu();
    initCountdowns();
    initUploadPreview();
    initBars();
    initConditional();
});
