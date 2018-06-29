// ==UserScript==
// @name       Di.fm Ad silencer
// @namespace  http://qmegas.info/difm
// @version    3.1
// @description  Silence ads on di.fm radio
// @include    https://*.di.fm/*
// @copyright  Megas (qmegas.info)
// @grant	   none
//
// ==/UserScript==

(() => {
	const initVars = () => {
		if (!di || !di.app || !di.app.vent) {
			return false;
		}
		di.app.vent.on("webplayer:ad:begin", () => {
            const muting = () => {
                if (!di.app.request("webplayer:muted")) {
                    console.log('Ad silencer - muting try');
                    di.app.commands.execute("webplayer:mute");
                    setTimeout(muting, 300);
                }
            };
            muting();
        });
		di.app.vent.on("webplayer:ad:end", () => {
            console.log('Ad silencer - unmuting');
            di.app.commands.execute("webplayer:unmute");
        });
		setInterval(() => di.app.vent.trigger("user:active"), 6e4);
        console.log('Ad silencer - init');
		return true;
	};

	const init = () => {
		if (!initVars()) {
			setTimeout(init, 1e3);
		}
	};

	$(init());
})();
