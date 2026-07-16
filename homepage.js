const startBtn = document.getElementById("startBtn");

if(startBtn) {
    startBtn.addEventListener("click",()=>{
        window.location.href="streetmode.html";
    });
}

window.addEventListener("load", ()=>{
    const savedSession = localStorage.getItem("lastWalk");
    if (savedSession) {
        const data = JSON.parse(savedSession);
        document.getElementById("lastWalkEmpty")
        ?.classList.add("hidden");

        document.getElementById("lastWalkData")
        ?.classList.remove("hidden");

        document.getElementById("duration").innerText = data.duration;

        document.getElementById("warnings").innerText = data.warnings;

        document.getElementById("result").innerText = data.result;
        
        document.getElementById("feedback").innerText = data.message;

    }
})