let seconds = 0;
let timeInterval;
let warningCount = 0;
let micStream;

function startTimer() {
    if (timeInterval) return;

    timeInterval=setInterval(()=>{
        seconds++;

        let min=Math.floor(seconds/60);
        let sec=seconds%60;

        document.getElementById("timer").innerText = String(min).padStart(2, "0") + ":" + String(sec).padStart(2,"0");
}, 1000);
}

// STOP TIMER FUNC

function stopTimer() {
    clearInterval(timeInterval)
}


// stop save session

const stopBtn = document.getElementById("stopBtn");
if (stopBtn) {
    stopBtn.onclick = () => {
        stopTimer();
        stopVehicleDetection();
        stopMicrophone();
        saveSession();
        window.location.href = "homepage.html";
    }
}

//save session
function saveSession() {
    let minutes=Math.floor(seconds/60);
    let sec=seconds%60;
    let duration = minutes + "m" + sec + "s"
    let result;
    let message;

    if (warningCount==0) {
        result="Good";
        message="Nicely done! You stayed aware!"
    }

    else if (warningCount<=3) {
        result="Okay"
        message="Decent walk. Stay sharper next time!"
    }

    else {
        result="Bad"
        message="You've got many warnings! Be more aware!"
    }

    localStorage.setItem(
        "lastWalk", JSON.stringify({
            duration:duration, warnings:warningCount, result:result, message:message
        })
    );
}

// if block microphone and activation microphone

async function activateMicrophone() {
    const micStatus = document.getElementById("micStatus");

    try {
        micStream = await navigator.mediaDevices.getUserMedia({
            audio: true
        })
        console.log("Microphone activated");
        if (micStatus) {
            micStatus.innerText = "LIVE";
            micStatus.classList.remove("offline");
            micStatus.classList.add("active");
            console.log("LIVE green activated");
        }
        
        }catch (error) {
            console.log(error.name);
            if (error.name === "NotAllowedError"){
                window.location.href ="denied.html"
            }
        }
    }

function stopMicrophone() {
    if (micStream) {
        micStream.getTracks().forEach(track => track.stop());
        console.log("Microphone stopped");
    }

}

function startVehicleDetection(){
console.log(
"AI vehicle detection started"
);

}




function stopVehicleDetection(){
console.log(
"AI vehicle detection stopped"
);


}


function triggerVehicleAlert(){
warningCount++;
console.log(
"Vehicle warning triggered"
);



}

window.onload=()=>{
startTimer();
activateMicrophone();
startVehicleDetection();

};