import { CONFIG } from './config.js';
import { Storage } from './storage.js';
import { SearchManager } from './search.js';
import { UI } from './ui.js';

console.log('Загрузка модулей...');
console.log('CONFIG:', CONFIG);

class BingAutoSearch {
    constructor() {
        console.log('Инициализация BingAutoSearch...');
        this.searchManager = new SearchManager();
        this.ui = new UI();
        this.timer = null;
        this.isRunning = false;
        this.currentSearch = 0;
        
        this.initialize();
        
        // Немедленный запуск после инициализации
        if (CONFIG.AUTO_START) {
            console.log('Автозапуск включен, запуск поиска...');
            this.start();
        } else {
            console.log('Автозапуск отключен в конфигурации');
        }
    }

    initialize() {
        console.log('Инициализация компонентов...');
        const settings = Storage.getSettings();
        this.ui.elements.searchLimit.value = this.searchManager.getSearchLimit();
        this.ui.elements.interval.value = CONFIG.DEFAULT_INTERVAL;
        this.ui.elements.multiTab.checked = settings.multiTab;

        this.ui.elements.startButton.addEventListener('click', () => this.start());
        this.ui.elements.stopButton.addEventListener('click', () => this.stop());
        
        this.ui.elements.searchLimit.addEventListener('change', () => this.saveSettings());
        this.ui.elements.interval.addEventListener('change', () => this.saveSettings());
        this.ui.elements.multiTab.addEventListener('change', () => this.saveSettings());
    }

    saveSettings() {
        const settings = {
            searchLimit: parseInt(this.ui.elements.searchLimit.value),
            interval: parseInt(this.ui.elements.interval.value),
            multiTab: this.ui.elements.multiTab.checked,
            theme: Storage.getSettings().theme
        };
        Storage.saveSettings(settings);
    }

    start() {
        if (this.isRunning) {
            console.log('Поиск уже запущен');
            return;
        }
        
        console.log('Запуск поиска...');
        this.isRunning = true;
        this.currentSearch = 0;
        this.totalSearches = this.searchManager.getSearchLimit();
        
        this.ui.toggleButtons(true);
        this.ui.showNotification(
            `Начало поиска в ${this.searchManager.currentMode === 'pc' ? 'ПК' : 'мобильном'} режиме`,
            'info'
        );
        this.performSearch();
    }

    stop() {
        if (!this.isRunning) {
            console.log('Поиск уже остановлен');
            return;
        }
        
        console.log('Остановка поиска...');
        this.isRunning = false;
        clearTimeout(this.timer);
        this.ui.toggleButtons(false);
        this.ui.updateTimer('00:00');
    }

    performSearch() {
        if (!this.isRunning) return;
        
        if (this.searchManager.isModeComplete()) {
            if (this.searchManager.currentMode === 'pc') {
                console.log('Переключение в мобильный режим...');
                this.searchManager.switchMode();
                this.ui.showNotification('Переключение в мобильный режим', 'info');
                this.currentSearch = 0;
                this.totalSearches = this.searchManager.getSearchLimit();
            } else {
                console.log('Поиск завершен');
                this.stop();
                this.ui.showNotification('Поиск завершен!', 'success');
                return;
            }
        }

        const searchTerm = this.searchManager.getNextSearchTerm();
        this.searchManager.performSearch(searchTerm);
        
        this.currentSearch++;
        this.ui.updateProgress(this.currentSearch, this.totalSearches);
        
        this.updateTimer(CONFIG.DEFAULT_INTERVAL);
        this.timer = setTimeout(() => this.performSearch(), CONFIG.DEFAULT_INTERVAL);
    }

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
            this.ui.updateTimer(`${minutes.toString().padStart(2, '0')}:${seconds.toString().padStart(2, '0')}`);
            
            if (timeLeft <= 0) {
                clearInterval(timerInterval);
            }
        }, 1000);
    }
}

// Инициализация приложения
console.log('Загрузка приложения...');
document.addEventListener('DOMContentLoaded', () => {
    console.log('DOM загружен, создание экземпляра BingAutoSearch...');
    window.bingAutoSearch = new BingAutoSearch();
});

// Добавляем дополнительную проверку
window.addEventListener('load', () => {
    console.log('Страница полностью загружена');
    if (!window.bingAutoSearch) {
        console.log('Создание экземпляра BingAutoSearch после полной загрузки...');
        window.bingAutoSearch = new BingAutoSearch();
    }
}); 