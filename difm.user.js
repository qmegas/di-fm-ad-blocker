// ==UserScript==
// @name       Di.fm Ad silencer
// @namespace  http://qmegas.info/difm
// @version    3.3
// @description  Remove ads on di.fm radio
// @include    https://*.di.fm/*
// @include    https://*.classicalradio.com/*
// @include    https://*.radiotunes.com/*
// @include    https://*.jazzradio.com/*
// @include    https://*.rockradio.com/*
// @copyright  Megas (qmegas.info)
// @grant	   none
//
// ==/UserScript==

(() => {
	const logger = msg => {
		const t = new Date();
		const timeStr = di.math.pad(t.getHours()) + ":" + di.math.pad(t.getMinutes()) + ":" + di.math.pad(t.getSeconds()) + "." + t.getMilliseconds();
		console.log('[' + timeStr + '] Ad silencer - ' + msg);
	};
	
	const silencer = {
		method1Silence: () => {
			di.app.vent.on("webplayer:ad:begin", () => {
				const muting = () => {
					if (!di.app.request("webplayer:muted")) {
						logger('muting try');
						di.app.commands.execute("webplayer:mute");
						setTimeout(muting, 300);
					}
				};
				muting();
			});
			di.app.vent.on("webplayer:ad:end", () => {
				logger('unmuting');
				di.app.commands.execute("webplayer:unmute");
			});
		},
		method2Remover: () => {
			di.app.reqres.setHandler('webplayer:interruptible', () => {
				logger('handled interruptible = false');
				return false;
			});
			di.app.reqres.setHandler('webplayer:ads:requestMidrollAd', () => {
				logger('handled requestMidrollAd');
				return {
					fail: e => {
						logger('requestMidrollAd fail');
						e();
					},
					done: e => false,
				};
			});
		},
		method3RemoverExperimental: () => di.app.WebplayerApp.Ads.Supervisor.timers.session.stop(),
		keepActive: () => setInterval(() => di.app.vent.trigger("user:active"), 60000),
	};
	
	const initVars = () => {
		if (!di || !di.app || !di.app.vent) {
			return false;
		}
		
		logger('init');
		silencer.method1Silence();
		silencer.method2Remover();
		silencer.keepActive();
		
		return true;
	};

	const init = () => {
		if (!initVars()) {
			setTimeout(init, 1000);
		}
	};

	$(init());
})();
