// Web通知機能
class WebNotificationService {
    constructor() {
        this.settings = this.loadSettings();
        this.lastCheckDate = localStorage.getItem('lastNotificationCheck') || '';
    }

    // 設定を読み込み
    loadSettings() {
        const saved = localStorage.getItem('web-notification-settings');
        if (saved) {
            try {
                return JSON.parse(saved);
            } catch (e) {
                console.error('Error loading notification settings:', e);
            }
        }
        return {
            enabled: false,
            salaryDayEnabled: false,
            salaryDay: 25,
            renewalEnabled: false,
            dailyCheckEnabled: true
        };
    }

    // 設定を保存
    saveSettings() {
        localStorage.setItem('web-notification-settings', JSON.stringify(this.settings));
    }

    // 通知許可をリクエスト
    async requestPermission() {
        console.log('通知許可をリクエスト中...');
        
        if (!('Notification' in window)) {
            console.error('通知APIが利用できません');
            alert('このブラウザは通知をサポートしていません。');
            return false;
        }

        console.log('現在の通知許可状態:', Notification.permission);

        if (Notification.permission === 'granted') {
            console.log('通知許可は既に有効です');
            return true;
        }

        if (Notification.permission === 'denied') {
            console.log('通知許可が拒否されています');
            alert('通知許可が拒否されています。ブラウザの設定から通知を許可してください。');
            return false;
        }

        try {
            console.log('通知許可ダイアログを表示します...');
            const permission = await Notification.requestPermission();
            console.log('通知許可の結果:', permission);
            return permission === 'granted';
        } catch (e) {
            console.error('通知許可のリクエストに失敗:', e);
            return false;
        }
    }

    // 通知を表示
    showNotification(title, body, icon = '💰') {
        console.log('showNotification called:', { title, body, permission: Notification.permission });
        
        if (!('Notification' in window)) {
            console.error('このブラウザは通知をサポートしていません');
            alert('このブラウザは通知をサポートしていません');
            return;
        }

        if (Notification.permission !== 'granted') {
            console.log('通知許可がありません。現在の許可状態:', Notification.permission);
            alert('通知許可がありません。通知設定から許可を確認してください。');
            return;
        }

        try {
            console.log('通知を作成中...');
            const options = {
                body: body,
                tag: 'qualification-allowance',
                requireInteraction: false,
                silent: false
            };
            
            console.log('通知オプション:', options);
            const notification = new Notification(title, options);
            
            console.log('通知が作成されました:', notification);

            notification.onshow = () => {
                console.log('通知が表示されました');
            };

            notification.onerror = (e) => {
                console.error('通知エラー:', e);
            };

            notification.onclick = () => {
                console.log('通知がクリックされました');
                window.focus();
                notification.close();
            };

            // 自動的に閉じる
            setTimeout(() => {
                console.log('通知を自動的に閉じます');
                notification.close();
            }, 10000);
        } catch (e) {
            console.error('通知の表示に失敗:', e);
            alert('通知の表示に失敗しました: ' + e.message);
        }
    }

    // テスト通知
    showTestNotification() {
        console.log('=== テスト通知を送信 ===');
        console.log('Notification in window:', 'Notification' in window);
        console.log('Notification.permission:', Notification.permission);
        
        this.showNotification(
            '🔔 テスト通知',
            '通知機能が正常に動作しています',
            '🔔'
        );
    }

    // 今日の日付をチェック
    getTodayString() {
        const today = new Date();
        return `${today.getFullYear()}-${today.getMonth() + 1}-${today.getDate()}`;
    }

    // 今日既にチェック済みか
    isCheckedToday() {
        return this.lastCheckDate === this.getTodayString();
    }

    // チェック日を記録
    markChecked() {
        this.lastCheckDate = this.getTodayString();
        localStorage.setItem('lastNotificationCheck', this.lastCheckDate);
    }

    // 給料日通知をチェック
    checkSalaryDayNotification(totalAllowance) {
        if (!this.settings.enabled || !this.settings.salaryDayEnabled) {
            return;
        }

        const today = new Date();
        const dayOfMonth = today.getDate();

        if (dayOfMonth === this.settings.salaryDay && !this.isCheckedToday()) {
            this.showNotification(
                '💰 今月の資格手当',
                `資格手当: ¥${totalAllowance.toLocaleString()}`,
                '💰'
            );
            this.markChecked();
        }
    }

    // 資格更新通知をチェック
    checkRenewalNotifications(acquiredCerts, certifications) {
        if (!this.settings.enabled || !this.settings.renewalEnabled) {
            return;
        }

        const today = new Date();
        today.setHours(0, 0, 0, 0);

        acquiredCerts.forEach(ac => {
            const cert = certifications.find(c => c.id === ac.certId);
            if (!cert) return;

            const expiryDate = new Date(ac.expiryDate);
            const daysUntilExpiry = Math.ceil((expiryDate - today) / (1000 * 60 * 60 * 24));

            // 更新可能期間（180日前または60日前）に通知
            const renewalDays = cert.validYears >= 3 ? 180 : 60;
            
            // 更新可能期間の初日に通知
            if (daysUntilExpiry === renewalDays || 
                (daysUntilExpiry === 30) || // 1ヶ月前
                (daysUntilExpiry === 7) ||  // 1週間前
                (daysUntilExpiry === 1)) {  // 前日
                
                let message = '';
                if (daysUntilExpiry === renewalDays) {
                    message = `${cert.name} の更新が可能になりました（あと${daysUntilExpiry}日）`;
                } else if (daysUntilExpiry === 30) {
                    message = `${cert.name} の有効期限まであと1ヶ月です`;
                } else if (daysUntilExpiry === 7) {
                    message = `${cert.name} の有効期限まであと1週間です`;
                } else if (daysUntilExpiry === 1) {
                    message = `${cert.name} の有効期限は明日です！`;
                }

                this.showNotification(
                    '📝 資格更新のお知らせ',
                    message,
                    '📝'
                );
            }

            // 期限切れ当日
            if (daysUntilExpiry === 0) {
                this.showNotification(
                    '⚠️ 資格期限切れ',
                    `${cert.name} の有効期限は本日までです`,
                    '⚠️'
                );
            }
        });
    }

    // すべての通知をチェック（ページ読み込み時）
    checkAllNotifications(acquiredCerts, certifications, totalAllowance) {
        if (!this.settings.enabled) {
            return;
        }

        // 給料日通知
        this.checkSalaryDayNotification(totalAllowance);

        // 資格更新通知（1日1回のみ）
        if (this.settings.dailyCheckEnabled && !this.isCheckedToday()) {
            this.checkRenewalNotifications(acquiredCerts, certifications);
            this.markChecked();
        }
    }

    // 定期チェックを開始（1時間ごと）
    startPeriodicCheck(getDataCallback) {
        setInterval(() => {
            const data = getDataCallback();
            this.checkAllNotifications(
                data.acquiredCerts,
                data.certifications,
                data.totalAllowance
            );
        }, 60 * 60 * 1000); // 1時間ごと
    }
}

// グローバルインスタンス
const webNotificationService = new WebNotificationService();

