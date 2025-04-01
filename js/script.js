const BING_AUTOSEARCH = {
    elements: {
        searchLimit: document.getElementById('searchLimit'),
        searchInterval: document.getElementById('searchInterval'),
        multitab: document.getElementById('multitab'),
        searchEngine: document.getElementById('searchEngine'),
        stopButton: document.getElementById('stopButton'),
        searchProgress: document.getElementById('searchProgress')
    },
    cookies: {
        help: 'bing_autosearch_help',
        searchInterval: 'bing_autosearch_interval',
        searchLimit: 'bing_autosearch_limit',
        multitab: 'bing_autosearch_multitab'
    },
    search: {
        current: 0,
        limit: 35,
        interval: 5,
        multitab: false,
        engine: {
            name: "bing",
            settings: "Bing Desktop",
            url: "https://www.bing.com/search?q=",
            icon: "bi bi-search"
        },
        mobile: {
            userAgent: "Mozilla/5.0 (iPhone; CPU iPhone OS 14_7_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/14.1.2 Mobile/15E148 Safari/604.1"
        }
    },
    setCookie: function(name, value, days) {
        let expires = "";
        if (days) {
            const date = new Date();
            date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
            expires = "; expires=" + date.toUTCString();
        }
        document.cookie = name + "=" + (value || "") + expires + "; path=/";
    },
    getCookie: function(name) {
        const nameEQ = name + "=";
        const ca = document.cookie.split(';');
        for(let i = 0; i < ca.length; i++) {
            let c = ca[i];
            while (c.charAt(0) === ' ') c = c.substring(1, c.length);
            if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length, c.length);
        }
        return null;
    },
    loadCookies: function() {
        if (!this.getCookie(this.cookies.help)) {
            this.setCookie(this.cookies.help, 'true', 365);
        }
        if (!this.getCookie(this.cookies.searchInterval)) {
            this.setCookie(this.cookies.searchInterval, this.search.interval, 365);
        }
        if (!this.getCookie(this.cookies.searchLimit)) {
            this.setCookie(this.cookies.searchLimit, this.search.limit, 365);
        }
        if (!this.getCookie(this.cookies.multitab)) {
            this.setCookie(this.cookies.multitab, this.search.multitab, 365);
        }
    },
    generateSearchTerms: function() {
        const terms = [];
        DEFAULT_CONFIG.terms.forEach(list => {
            terms.push(...list);
        });
        return terms;
    },
    getRandomSearchTerm: function() {
        const terms = this.generateSearchTerms();
        return terms[Math.floor(Math.random() * terms.length)];
    },
    getSearchInterval: function() {
        return parseInt(this.getCookie(this.cookies.searchInterval)) * 60 * 1000;
    },
    updateProgress: function() {
        const progress = (this.search.current / this.search.limit) * 100;
        this.elements.searchProgress.style.width = progress + '%';
        this.elements.searchProgress.textContent = Math.round(progress) + '%';
    },
    start: function() {
        this.search.current = 0;
        this.search.limit = parseInt(this.getCookie(this.cookies.searchLimit));
        this.search.interval = this.getSearchInterval();
        this.search.multitab = this.getCookie(this.cookies.multitab) === 'true';
        this.next();
    },
    stop: function() {
        this.search.current = 0;
        this.updateProgress();
    },
    next: function() {
        if (this.search.current >= this.search.limit) {
            this.complete();
            return;
        }
        const term = this.getRandomSearchTerm();
        const url = this.search.engine.url + encodeURIComponent(term);
        if (this.search.multitab) {
            window.open(url, '_blank');
        } else {
            window.location.href = url;
        }
        this.search.current++;
        this.updateProgress();
        setTimeout(() => this.next(), this.search.interval);
    },
    complete: function() {
        this.search.current = 0;
        this.updateProgress();
    }
};

document.addEventListener('DOMContentLoaded', function() {
    BING_AUTOSEARCH.loadCookies();
    BING_AUTOSEARCH.elements.searchLimit.value = BING_AUTOSEARCH.getCookie(BING_AUTOSEARCH.cookies.searchLimit);
    BING_AUTOSEARCH.elements.searchInterval.value = BING_AUTOSEARCH.getCookie(BING_AUTOSEARCH.cookies.searchInterval);
    BING_AUTOSEARCH.elements.multitab.checked = BING_AUTOSEARCH.getCookie(BING_AUTOSEARCH.cookies.multitab) === 'true';
    BING_AUTOSEARCH.start();

    BING_AUTOSEARCH.elements.stopButton.addEventListener('click', function() {
        BING_AUTOSEARCH.stop();
    });
});