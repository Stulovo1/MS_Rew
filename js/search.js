import { CONFIG } from './config.js';

export class SearchManager {
    constructor() {
        console.log('Инициализация SearchManager...');
        this.currentMode = 'pc';
        this.currentIndex = 0;
        this.searchTerms = this.generateSearchTerms();
    }

    getSearchLimit() {
        return this.currentMode === 'pc' ? 
            CONFIG.DEFAULT_SEARCH_LIMIT_PC : 
            CONFIG.DEFAULT_SEARCH_LIMIT_MOBILE;
    }

    isModeComplete() {
        return this.currentIndex >= this.searchTerms.length;
    }

    switchMode() {
        this.currentMode = this.currentMode === 'pc' ? 'mobile' : 'pc';
        this.currentIndex = 0;
    }

    getNextSearchTerm() {
        if (this.currentIndex >= this.searchTerms.length) {
            this.currentIndex = 0;
        }
        return this.searchTerms[this.currentIndex++];
    }

    performSearch(term) {
        const url = this.currentMode === 'pc' ? 
            CONFIG.SEARCH.PC_URL : 
            CONFIG.SEARCH.MOBILE_URL;
            
        const searchUrl = url + encodeURIComponent(term);
        window.open(searchUrl, '_blank');
    }

    generateSearchTerms() {
        const terms = [];
        for (let i = 0; i < 100; i++) {
            terms.push(`search term ${i + 1}`);
        }
        return terms;
    }
} 