import { CONFIG } from './config.js';

export class Storage {
    static getSettings() {
        console.log('Загрузка настроек...');
        const settings = localStorage.getItem(CONFIG.STORAGE_KEYS.SETTINGS);
        if (settings) {
            return JSON.parse(settings);
        }
        return {
            searchLimit: CONFIG.DEFAULT_SEARCH_LIMIT_PC,
            interval: CONFIG.DEFAULT_INTERVAL,
            multiTab: CONFIG.DEFAULT_MULTITAB,
            theme: CONFIG.UI.DEFAULT_THEME
        };
    }

    static saveSettings(settings) {
        console.log('Сохранение настроек...');
        localStorage.setItem(CONFIG.STORAGE_KEYS.SETTINGS, JSON.stringify(settings));
    }
} 