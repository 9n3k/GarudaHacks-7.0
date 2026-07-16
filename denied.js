const retryBtn = document.getElementById("retryBtn");
const homeBtn = document.getElementById("homeBtn");

if (retryBtn) {
    retryBtn.onclick = () => {
        window.location.href = "streetmode.html";
    }
}

if (homeBtn) {
    homeBtn.onclick = () => {
        window.location.href = "homepage.html";
    }
}