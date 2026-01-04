// 資格マスターデータ
const certifications = [
    // Google Cloud - Associate
    { id: 'cdl', name: 'Cloud Digital Leader', category: 'Google Cloud', allowance: 5000, validYears: 3 },
    { id: 'gail', name: 'Generative AI Leader', category: 'Google Cloud', allowance: 5000, validYears: 3 },
    { id: 'ace', name: 'Associate Cloud Engineer', category: 'Google Cloud', allowance: 5000, validYears: 3 },
    { id: 'agwa', name: 'Associate Google Workspace Administrator', category: 'Google Cloud', allowance: 5000, validYears: 3 },
    { id: 'adp', name: 'Associate Data Practitioner', category: 'Google Cloud', allowance: 5000, validYears: 3 },
    
    // Google Cloud - Professional
    { id: 'pca', name: 'Professional Cloud Architect', category: 'Google Cloud', allowance: 10000, validYears: 2 },
    { id: 'pdbe', name: 'Professional Database Engineer', category: 'Google Cloud', allowance: 10000, validYears: 2 },
    { id: 'pcdev', name: 'Professional Cloud Developer', category: 'Google Cloud', allowance: 10000, validYears: 2 },
    { id: 'pde', name: 'Professional Data Engineer', category: 'Google Cloud', allowance: 10000, validYears: 2 },
    { id: 'pcdoe', name: 'Professional Cloud DevOps Engineer', category: 'Google Cloud', allowance: 10000, validYears: 2 },
    { id: 'pcse', name: 'Professional Cloud Security Engineer', category: 'Google Cloud', allowance: 10000, validYears: 2 },
    { id: 'pcne', name: 'Professional Cloud Network Engineer', category: 'Google Cloud', allowance: 10000, validYears: 2 },
    { id: 'pmle', name: 'Professional Machine Learning Engineer', category: 'Google Cloud', allowance: 10000, validYears: 2 },
    { id: 'psoe', name: 'Professional Security Operations Engineer', category: 'Google Cloud', allowance: 10000, validYears: 2 },
    
    // その他
    { id: 'pcoa', name: 'Professional ChromeOS Administrator', category: 'Chrome OS', allowance: 5000, validYears: 3 },
    { id: 'ckad', name: 'Certified Kubernetes Application Developer', category: 'CNCF', allowance: 10000, validYears: 3 },
    { id: 'cka', name: 'Certified Kubernetes Administrator', category: 'CNCF', allowance: 10000, validYears: 3 },
    { id: 'pmp', name: 'PMP', category: 'PMI', allowance: 10000, validYears: 3 }
];

// 状態管理
let acquiredCerts = [];
let currentFilter = 'all';

// LocalStorageのキー
const STORAGE_KEY = 'qualification-allowance-data';
const THEME_KEY = 'qualification-allowance-theme';

// ページ読み込み時の初期化
document.addEventListener('DOMContentLoaded', () => {
    loadTheme();
    loadData();
    initializeUI();
    updateUI();
    initializeThemeSwitcher();
    initializeNotifications();
    
    // 通知チェックを開始
    checkNotificationsOnLoad();
});

// データ読み込み
function loadData() {
    const savedData = localStorage.getItem(STORAGE_KEY);
    if (savedData) {
        try {
            acquiredCerts = JSON.parse(savedData);
            console.log('Loaded data:', acquiredCerts);
        } catch (e) {
            console.error('Error loading data:', e);
            acquiredCerts = [];
        }
    } else {
        acquiredCerts = [];
        console.log('No saved data found');
    }
}

// データ保存
function saveData() {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(acquiredCerts));
}

// UI初期化
function initializeUI() {
    // 資格選択ドロップダウンを設定
    const certSelect = document.getElementById('certSelect');
    certifications.forEach(cert => {
        const option = document.createElement('option');
        option.value = cert.id;
        option.textContent = `${cert.name} (${cert.category}) - ¥${cert.allowance.toLocaleString()}/月`;
        certSelect.appendChild(option);
    });

    // マスターテーブルを設定
    populateMasterTable();

    // イベントリスナーを設定
    document.getElementById('addCertBtn').addEventListener('click', addCertification);
    document.getElementById('resetDataBtn').addEventListener('click', resetData);

    // フィルターボタン
    document.querySelectorAll('.filter-btn').forEach(btn => {
        btn.addEventListener('click', (e) => {
            document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
            e.target.classList.add('active');
            currentFilter = e.target.dataset.filter;
            updateCertList();
        });
    });
}

// マスターテーブルを設定
function populateMasterTable() {
    const tbody = document.getElementById('masterTableBody');
    tbody.innerHTML = '';

    certifications.forEach(cert => {
        const row = document.createElement('tr');
        const isAcquired = acquiredCerts.some(ac => ac.certId === cert.id);
        if (isAcquired) {
            row.classList.add('acquired');
        }

        row.innerHTML = `
            <td>${cert.name}</td>
            <td>${cert.category}</td>
            <td>¥${cert.allowance.toLocaleString()}</td>
            <td>${cert.validYears}年</td>
        `;
        tbody.appendChild(row);
    });
}

// 資格追加
function addCertification() {
    const certSelect = document.getElementById('certSelect');
    const acquireDate = document.getElementById('acquireDate');

    if (!certSelect.value || !acquireDate.value) {
        alert('資格と取得日を選択してください。');
        return;
    }

    // すでに取得済みかチェック
    if (acquiredCerts.some(cert => cert.certId === certSelect.value)) {
        alert('この資格はすでに登録されています。');
        return;
    }

    const cert = certifications.find(c => c.id === certSelect.value);
    const acquired = new Date(acquireDate.value);
    const expiry = new Date(acquired);
    expiry.setFullYear(expiry.getFullYear() + cert.validYears);

    acquiredCerts.push({
        certId: cert.id,
        acquiredDate: acquireDate.value,
        expiryDate: expiry.toISOString().split('T')[0]
    });

    saveData();
    updateUI();

    // フォームをリセット
    certSelect.value = '';
    acquireDate.value = '';

    alert('資格を追加しました！');
}

// 資格削除
function removeCertification(certId) {
    if (confirm('この資格を削除してもよろしいですか？')) {
        acquiredCerts = acquiredCerts.filter(cert => cert.certId !== certId);
        saveData();
        updateUI();
    }
}

// データリセット
function resetData() {
    if (confirm('すべてのデータをリセットしてもよろしいですか？\nこの操作は取り消せません。')) {
        acquiredCerts = [];
        saveData();
        updateUI();
        alert('データをリセットしました。');
    }
}

// UI更新
function updateUI() {
    updateSummary();
    updateAlerts();
    updateCertList();
    populateMasterTable();
}

// サマリー更新
function updateSummary() {
    let totalAllowance = 0;
    acquiredCerts.forEach(ac => {
        const cert = certifications.find(c => c.id === ac.certId);
        if (cert) {
            totalAllowance += cert.allowance;
        }
    });

    // 上限チェック
    if (totalAllowance > 100000) {
        totalAllowance = 100000;
    }

    document.getElementById('totalAllowance').textContent = `¥${totalAllowance.toLocaleString()}`;
    document.getElementById('certCount').textContent = acquiredCerts.length;

    // 更新必要な資格数をカウント
    const expiringCerts = getExpiringCerts();
    document.getElementById('expiringCount').textContent = expiringCerts.length;
}

// アラート更新
function updateAlerts() {
    const expiringCerts = getExpiringCerts();
    const alertSection = document.getElementById('alertSection');
    const alertList = document.getElementById('alertList');

    if (expiringCerts.length > 0) {
        alertSection.style.display = 'block';
        alertList.innerHTML = '';

        expiringCerts.forEach(ac => {
            const cert = certifications.find(c => c.id === ac.certId);
            const daysUntilExpiry = getDaysUntilExpiry(ac.expiryDate);
            const statusMessage = getExpiryStatusMessage(ac.certId, daysUntilExpiry);
            const li = document.createElement('li');

            li.textContent = `${cert.name} - ${statusMessage}`;
            alertList.appendChild(li);
        });
    } else {
        alertSection.style.display = 'none';
    }
}

// 資格リスト更新
function updateCertList() {
    const container = document.getElementById('certListContainer');

    let certs = [...acquiredCerts];

    // フィルター適用
    if (currentFilter === 'expiring') {
        const expiringIds = getExpiringCerts().map(c => c.certId);
        certs = certs.filter(c => expiringIds.includes(c.certId));
    } else if (currentFilter === 'valid') {
        const expiringIds = getExpiringCerts().map(c => c.certId);
        certs = certs.filter(c => !expiringIds.includes(c.certId));
    }

    if (certs.length === 0) {
        container.innerHTML = '<p class="empty-message">該当する資格がありません。</p>';
        return;
    }

    container.innerHTML = '';
    certs.forEach(ac => {
        const cert = certifications.find(c => c.id === ac.certId);
        const daysUntilExpiry = getDaysUntilExpiry(ac.expiryDate);
        const isExpired = daysUntilExpiry < 0;
        const isExpiring = daysUntilExpiry <= 90 && !isExpired;
        const statusMessage = getExpiryStatusMessage(ac.certId, daysUntilExpiry);

        const card = document.createElement('div');
        // 色分け: 期限切れ=赤、更新必要=オレンジ
        card.className = `cert-card ${isExpired ? 'expired' : isExpiring ? 'expiring' : ''}`;

        let expiryClass = isExpired ? 'expired' : isExpiring ? 'expiring' : '';

        card.innerHTML = `
            <div class="cert-info">
                <h3>${cert.name}</h3>
                <span class="category">${cert.category}</span>
                <div class="cert-details">
                    <div class="detail-item">
                        <span class="detail-label">取得日</span>
                        <span class="detail-value">${ac.acquiredDate}</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">有効期限</span>
                        <span class="detail-value ${expiryClass}">${ac.expiryDate}</span>
                        <span class="detail-badge ${expiryClass}">${statusMessage}</span>
                    </div>
                    <div class="detail-item">
                        <span class="detail-label">月額手当</span>
                        <span class="detail-value">¥${cert.allowance.toLocaleString()}</span>
                    </div>
                </div>
            </div>
            <div>
                <button class="btn-remove" onclick="removeCertification('${cert.id}')">削除</button>
            </div>
        `;

        container.appendChild(card);
    });
}

// 更新が必要な資格を取得（90日以内または期限切れ）
function getExpiringCerts() {
    return acquiredCerts.filter(ac => {
        const daysUntilExpiry = getDaysUntilExpiry(ac.expiryDate);
        return daysUntilExpiry <= 90;
    });
}

// 有効期限までの日数を計算
function getDaysUntilExpiry(expiryDate) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const expiry = new Date(expiryDate);
    expiry.setHours(0, 0, 0, 0);
    const diffTime = expiry - today;
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    return diffDays;
}

// 更新可能かどうか
function canRenew(certId, daysUntilExpiry) {
    const cert = certifications.find(c => c.id === certId);
    if (!cert) return false;
    // Professional（2年）: 60日前から
    // Associate/Foundational（3年）: 180日前から
    const renewalDays = cert.validYears >= 3 ? 180 : 60;
    return daysUntilExpiry <= renewalDays;
}

// 有効期限ステータスメッセージを取得（更新可能状態も含む）
function getExpiryStatusMessage(certId, daysUntilExpiry) {
    // 期限切れ
    if (daysUntilExpiry < 0) {
        return `${Math.abs(daysUntilExpiry)}日超過（期限切れ）`;
    }
    
    // 本日が期限
    if (daysUntilExpiry === 0) {
        return '本日が期限';
    }
    
    // 更新可能かチェック
    if (canRenew(certId, daysUntilExpiry)) {
        return `あと${daysUntilExpiry}日（更新可能）`;
    }
    
    // 通常
    return `あと${daysUntilExpiry}日`;
}

// テーマ管理
function loadTheme() {
    const savedTheme = localStorage.getItem(THEME_KEY) || 'light';
    applyTheme(savedTheme);
}

function saveTheme(theme) {
    localStorage.setItem(THEME_KEY, theme);
}

function applyTheme(theme) {
    document.documentElement.setAttribute('data-theme', theme);
    
    // アクティブなテーマオプションを更新
    document.querySelectorAll('.theme-option').forEach(option => {
        option.classList.toggle('active', option.dataset.theme === theme);
    });
}

function initializeThemeSwitcher() {
    const themeBtn = document.getElementById('themeBtn');
    const themeModal = document.getElementById('themeModal');
    const closeModal = document.getElementById('closeModal');

    // テーマボタンクリック
    themeBtn.addEventListener('click', () => {
        themeModal.classList.add('show');
    });

    // モーダルを閉じる
    closeModal.addEventListener('click', () => {
        themeModal.classList.remove('show');
    });

    // モーダル外をクリックで閉じる
    themeModal.addEventListener('click', (e) => {
        if (e.target === themeModal) {
            themeModal.classList.remove('show');
        }
    });

    // テーマオプションクリック
    document.querySelectorAll('.theme-option').forEach(option => {
        option.addEventListener('click', () => {
            const theme = option.dataset.theme;
            applyTheme(theme);
            saveTheme(theme);
        });
    });
}

// 通知機能を初期化
function initializeNotifications() {
    const notificationBtn = document.getElementById('notificationBtn');
    const notificationModal = document.getElementById('notificationModal');
    const closeNotificationModal = document.getElementById('closeNotificationModal');

    // 通知ボタンクリック
    notificationBtn.addEventListener('click', () => {
        notificationModal.classList.add('show');
        updateNotificationUI();
    });

    // モーダルを閉じる
    closeNotificationModal.addEventListener('click', () => {
        notificationModal.classList.remove('show');
    });

    // モーダル外をクリックで閉じる
    notificationModal.addEventListener('click', (e) => {
        if (e.target === notificationModal) {
            notificationModal.classList.remove('show');
        }
    });

    // 通知許可リクエスト
    document.getElementById('requestPermissionBtn').addEventListener('click', async () => {
        const granted = await webNotificationService.requestPermission();
        updatePermissionStatus();
        if (granted) {
            alert('通知許可が有効になりました');
        } else {
            alert('通知許可が拒否されました。ブラウザの設定から許可してください。');
        }
    });

    // 通知機能有効化トグル
    document.getElementById('notificationEnabled').addEventListener('change', (e) => {
        webNotificationService.settings.enabled = e.target.checked;
        webNotificationService.saveSettings();
    });

    // 給料日通知トグル
    document.getElementById('salaryDayEnabled').addEventListener('change', (e) => {
        webNotificationService.settings.salaryDayEnabled = e.target.checked;
        webNotificationService.saveSettings();
    });

    // 給料日スライダー
    const salaryDaySlider = document.getElementById('salaryDaySlider');
    const salaryDayValue = document.getElementById('salaryDayValue');
    salaryDaySlider.addEventListener('input', (e) => {
        salaryDayValue.textContent = e.target.value;
    });
    salaryDaySlider.addEventListener('change', (e) => {
        webNotificationService.settings.salaryDay = parseInt(e.target.value);
        webNotificationService.saveSettings();
    });

    // 資格更新通知トグル
    document.getElementById('renewalEnabled').addEventListener('change', (e) => {
        webNotificationService.settings.renewalEnabled = e.target.checked;
        webNotificationService.saveSettings();
    });

    // テスト通知
    document.getElementById('testNotificationBtn').addEventListener('click', () => {
        webNotificationService.showTestNotification();
    });

    // 定期チェックを開始
    webNotificationService.startPeriodicCheck(() => {
        return {
            acquiredCerts: acquiredCerts,
            certifications: certifications,
            totalAllowance: calculateTotalAllowance()
        };
    });
}

// 通知UIを更新
function updateNotificationUI() {
    const settings = webNotificationService.settings;
    
    document.getElementById('notificationEnabled').checked = settings.enabled;
    document.getElementById('salaryDayEnabled').checked = settings.salaryDayEnabled;
    document.getElementById('renewalEnabled').checked = settings.renewalEnabled;
    document.getElementById('salaryDaySlider').value = settings.salaryDay;
    document.getElementById('salaryDayValue').textContent = settings.salaryDay;
    
    updatePermissionStatus();
}

// 通知許可ステータスを更新
function updatePermissionStatus() {
    const statusElement = document.getElementById('permissionStatus');
    if (!('Notification' in window)) {
        statusElement.textContent = '❌ このブラウザは通知をサポートしていません';
        statusElement.style.color = '#e74c3c';
    } else if (Notification.permission === 'granted') {
        statusElement.textContent = '✅ 通知許可が有効です';
        statusElement.style.color = '#27ae60';
    } else if (Notification.permission === 'denied') {
        statusElement.textContent = '❌ 通知許可が拒否されています';
        statusElement.style.color = '#e74c3c';
    } else {
        statusElement.textContent = '⚠️ 通知許可がまだ設定されていません';
        statusElement.style.color = '#f39c12';
    }
}

// ページ読み込み時に通知をチェック
function checkNotificationsOnLoad() {
    const totalAllowance = calculateTotalAllowance();
    webNotificationService.checkAllNotifications(
        acquiredCerts,
        certifications,
        totalAllowance
    );
}

// 合計手当を計算
function calculateTotalAllowance() {
    let total = 0;
    acquiredCerts.forEach(ac => {
        const cert = certifications.find(c => c.id === ac.certId);
        if (cert) {
            const daysUntilExpiry = getDaysUntilExpiry(ac.expiryDate);
            if (daysUntilExpiry >= 0) {
                total += cert.allowance;
            }
        }
    });
    return total > 100000 ? 100000 : total;
}

// デバッグ用（コンソールから呼び出し可能）
function debugInfo() {
    console.log('Certifications:', certifications);
    console.log('Acquired Certs:', acquiredCerts);
    console.log('Expiring Certs:', getExpiringCerts());
}

