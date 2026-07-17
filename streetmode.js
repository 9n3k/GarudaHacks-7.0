let seconds = 0;
let timeInterval;
let warningCount = 0;
let micStream;
let recorder;

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
            console.log("Microphone error:", error);
                window.location.href ="denied.html"
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

    recorder = new MediaRecorder(micStream);
    

    recorder.ondataavailable = async(event) => {
        console.log("Blob type:", event.data.type);
        console.log("Blob size:", event.data.size);
        try{
            let response = await fetch(
                "http://127.0.0.1:5000/detect",
                {
                    method: "POST",
                    headers: {
                        "Content-Type": "audio/webm"
                    },
                    body:event.data
                }
            )
            let result = await response.json();
            console.log("AI result:", result);
            if (result.result === "ALERT") {
                triggerVehicleAlert();
            }
        }
        catch (error) {
            console.log ("AI server error:", error)
        }
    };

    recorder.start(3000);
    }


function stopVehicleDetection() {
    console.log("AI vehicle detection stopped");

    if (recorder && recorder.state != "inactive") {
        recorder.stop();
    }
}


function triggerVehicleAlert(){
warningCount++;
localStorage.setItem (
    "warningCount", warningCount
);
window.location.href = "warning.html";
}



window.onload=async()=> {
    startTimer();
    await activateMicrophone();
    startVehicleDetection();
}

