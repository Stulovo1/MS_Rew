export const CONFIG = {
    // Основные настройки
    DEFAULT_SEARCH_LIMIT_PC: 40,
    DEFAULT_SEARCH_LIMIT_MOBILE: 30,
    DEFAULT_INTERVAL: 300000, // 5 минут
    DEFAULT_MULTITAB: false,
    AUTO_START: true, // Включаем автозапуск
    
    // Интервалы поиска (в миллисекундах)
    INTERVALS: {
        FIVE_MINUTES: 300000
    },
    
    // Лимиты поиска
    SEARCH_LIMITS: {
        PC: [20, 30, 35, 40, 45, 50],
        MOBILE: [20, 25, 30, 35, 40]
    },
    
    // Настройки cookies
    COOKIE_SETTINGS: {
        EXPIRES_DAYS: 365,
        PATH: '/'
    },
    
    // Ключи для localStorage
    STORAGE_KEYS: {
        SETTINGS: 'bing_autosearch_settings',
        CUSTOM_SEARCHES: 'bing_autosearch_custom_searches',
        STATISTICS: 'bing_autosearch_statistics',
        SEARCH_MODE: 'bing_autosearch_mode' // 'pc' или 'mobile'
    },
    
    // Настройки UI
    UI: {
        THEMES: ['light', 'dark'],
        DEFAULT_THEME: 'light',
        ANIMATION_DURATION: 300
    },
    
    // Настройки безопасности
    SECURITY: {
        MAX_CUSTOM_SEARCHES: 100,
        MAX_SEARCH_LENGTH: 100
    },
    
    // Настройки поиска
    SEARCH: {
        PC_URL: 'https://www.bing.com/search?q=',
        MOBILE_URL: 'https://www.bing.com/search?q=',
        MOBILE_USER_AGENT: 'Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1'
    }
}; 