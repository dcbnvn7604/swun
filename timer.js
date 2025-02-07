class Timer {
    timer = (minutes=10) => {
        this.startAt = Date.now();
        this._checkPermission();
        console.log(`timer start at:${new Date()}`);
        this.timeout = setTimeout(this.finish, minutes * 60 * 1000);
    }

    stopT  = () => {
        clearTimeout(this.timeout);
        this.startAt = null;
    }

    spendT = () => {
        if (!this.startAt) {
            throw 'Not start';
        }
        let spend = (Date.now() - this.startAt) / 1000 / 60;
        console.log(`spend: ${spend.toFixed(1)} minutes`);
    }

    finish = () => {
        this.startAt = null;
        new Notification("Timeout");
    }

    requestPermission = () => {
        let button = document.createElement("button");
        button.innerHTML = "Request permission";
        button.addEventListener('click', () => {Notification.requestPermission()});
        document.body.appendChild(button);
    }

    alarm = (at) => {
        this._checkPermission();
        if (!at) {
            throw 'Alarm: No time';
        }
        let parts = at.match(/(\d{2}):(\d{2})/);
        if (!parts) {
            throw 'Alarm: Wrong time';
        }
        let alarmAt = new Date();
        alarmAt.setHours(parts[1], parts[2]);
        this.alarmer = setTimeout(this.finish, alarmAt.getTime() - Date.now());
        console.log(`alarm at:${alarmAt}`);
    }

    stopA  = () => {
        clearTimeout(this.alarmer);
    }

    _checkPermission = () => {
        if (Notification.permission !== "granted") {
            throw 'No permission';
        }
    }
};
let _t = new Timer();
window.t=_t.timer;
window.a=_t.alarm;