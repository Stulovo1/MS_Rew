const BING_AUTOSEARCH = {
    elements: {
        startButton: document.getElementById('startButton'),
        stopButton: document.getElementById('stopButton'),
        searchLimit: document.getElementById('searchLimit'),
        interval: document.getElementById('interval'),
        multiTab: document.getElementById('multiTab'),
        progressCounter: document.getElementById('progressCounter'),
        timer: document.getElementById('timer')
    },

    timer: null,
    isRunning: false,
    currentSearch: 0,
    currentMode: 'pc',
    searchTerms: [],

    init() {
        this.loadSettings();
        this.setupEventListeners();
        this.generateSearchTerms();
        
        // Автозапуск при инициализации
        this.start();
    },

    loadSettings() {
        const settings = JSON.parse(localStorage.getItem('settings') || '{}');
        this.elements.searchLimit.value = settings.searchLimit || 35;
        this.elements.interval.value = settings.interval || 10000;
        this.elements.multiTab.checked = settings.multiTab || false;
    },

    setupEventListeners() {
        this.elements.startButton.addEventListener('click', () => this.start());
        this.elements.stopButton.addEventListener('click', () => this.stop());
        this.elements.searchLimit.addEventListener('change', () => this.saveSettings());
        this.elements.interval.addEventListener('change', () => this.saveSettings());
        this.elements.multiTab.addEventListener('change', () => this.saveSettings());
    },

    saveSettings() {
        const settings = {
            searchLimit: parseInt(this.elements.searchLimit.value),
            interval: parseInt(this.elements.interval.value),
            multiTab: this.elements.multiTab.checked
        };
        localStorage.setItem('settings', JSON.stringify(settings));
    },

    start() {
        if (this.isRunning) return;
        
        this.isRunning = true;
        this.currentSearch = 0;
        this.totalSearches = parseInt(this.elements.searchLimit.value);
        
        this.elements.startButton.disabled = true;
        this.elements.stopButton.disabled = false;
        
        this.performSearch();
    },

    stop() {
        if (!this.isRunning) return;
        
        this.isRunning = false;
        clearTimeout(this.timer);
        
        this.elements.startButton.disabled = false;
        this.elements.stopButton.disabled = true;
        this.elements.timer.textContent = '00:00';
    },

    performSearch() {
        if (!this.isRunning) return;
        
        if (this.currentSearch >= this.totalSearches) {
            if (this.currentMode === 'pc') {
                this.currentMode = 'mobile';
                this.currentSearch = 0;
                this.totalSearches = Math.min(this.totalSearches, 30);
            } else {
                this.stop();
                return;
            }
        }

        const searchTerm = this.searchTerms[Math.floor(Math.random() * this.searchTerms.length)];
        const url = this.currentMode === 'pc' ? 
            'https://www.bing.com/search?q=' : 
            'https://www.bing.com/search?q=';
            
        window.open(url + encodeURIComponent(searchTerm), '_blank');
        
        this.currentSearch++;
        this.elements.progressCounter.textContent = `${this.currentSearch}/${this.totalSearches}`;
        
        const progress = (this.currentSearch / this.totalSearches) * 100;
        document.querySelector('.progress-bar').style.width = `${progress}%`;
        
        this.updateTimer(parseInt(this.elements.interval.value));
        this.timer = setTimeout(() => this.performSearch(), parseInt(this.elements.interval.value));
    },

    updateTimer(interval) {
        let timeLeft = interval / 1000;
        const timerInterval = setInterval(() => {
            if (!this.isRunning) {
                clearInterval(timerInterval);
                return;
            }
            
            timeLeft--;
            const minutes = Math.floor(timeLeft / 60);
            const seconds = timeLeft % 60;
            this.elements.timer.textContent = 
                `${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`;
            
            if (timeLeft <= 0) {
                clearInterval(timerInterval);
            }
        }, 1000);
    },

    generateSearchTerms() {
        const terms = [];
        for (let i = 0; i < 100; i++) {
            terms.push(`search term ${i + 1}`);
        }
        this.searchTerms = terms;
    },

    setCookie(name, value, days = 365) {
        const date = new Date();
        date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
        const expires = `expires=${date.toUTCString()}`;
        document.cookie = `${name}=${value};${expires};path=/`;
    },

    getCookie(name) {
        const value = `; ${document.cookie}`;
        const parts = value.split(`; ${name}=`);
        if (parts.length === 2) return parts.pop().split(';').shift();
    }
};

// Инициализация при полной загрузке страницы
window.addEventListener('load', () => {
    console.log('Страница полностью загружена, запуск приложения...');
    BING_AUTOSEARCH.init();
}); 