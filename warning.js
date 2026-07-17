let warningSound = new Audio("./warning.mp3");

//warning audio
function playWarningSound(){
    warningSound.loop = true;
    warningSound.volume = 1;
    warningSound.play()
    .then(()=>{
        console.log("audio started");
    })
    .catch(error=>{
        console.log("audio failed:", error);
    });

}


window.onload=()=>{
    console.log("warning.js loaded");
    setTimeout(()=>{
        playWarningSound();
    },1000);
    activateVibration();
    sendNotification();

};


function activateVibration() {
    if ("vibrate" in navigator) {

        navigator.vibrate([
            500,
            200,
            500,
            200,
            1000
        ]);
        console.log("Vibration activated")
    }
    else{
        console.log("Vibration not supported");
    }
}

function addWarning() {
    let current = JSON.parse(localStorage.getItem("lastWalk")) || {
        duration: "0m0s",
        warnings: 0,
        result:"Good",
        message:""
    }
    current.warnings++;
    localStorage.setItem(
        "lastWalk", 
        JSON.stringify(current)
    )
    console.log("Warning added");

}

function sendNotification () {
    if (Notification.permission==="granted") {
        new Notification(
            "⚠️ Vehicle Detected",
            {
                body:
                "VEHICLE APPROACHING! LOOK AROUND IMMEDIATELY!",
                icon:"notif.png"
            }
        );

    }

    else if(Notification.permission!=="denied"){
        Notification.requestPermission();
    }
}

function stopWarning() {
    warningSound.pause();
    warningSound.currentTime = 0;
    navigator.vibrate(0);
}
const closeBtn = document.getElementById("closeWarning");

if (closeBtn) {
    closeBtn.onclick=() => {
        stopWarning();
        addWarning();
        window.location.href = "streetmode.html"
    }
}



window.onload=()=>{
    playWarningSound();
    activateVibration();
    sendNotification();

};