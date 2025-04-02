export class UI {
    constructor() {
        console.log('Инициализация UI...');
        this.elements = {
            startButton: document.getElementById('startButton'),
            stopButton: document.getElementById('stopButton'),
            searchLimit: document.getElementById('searchLimit'),
            interval: document.getElementById('interval'),
            multiTab: document.getElementById('multiTab'),
            progressCounter: document.getElementById('progressCounter'),
            timer: document.getElementById('timer')
        };
    }

    toggleButtons(isRunning) {
        this.elements.startButton.disabled = isRunning;
        this.elements.stopButton.disabled = !isRunning;
    }

    updateProgress(current, total) {
        this.elements.progressCounter.textContent = `${current}/${total}`;
        const progress = (current / total) * 100;
        document.querySelector('.progress-bar').style.width = `${progress}%`;
    }

    updateTimer(time) {
        this.elements.timer.textContent = time;
    }

    showNotification(message, type = 'info') {
        console.log(`[${type}] ${message}`);
    }
} 