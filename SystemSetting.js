import {NativeModules, NativeEventEmitter} from 'react-native'

import Utils from './Utils'

const SystemSettingNative = NativeModules.SystemSetting

const SCREEN_BRIGHTNESS_MODE_UNKNOW = -1
const SCREEN_BRIGHTNESS_MODE_MANUAL = 0
const SCREEN_BRIGHTNESS_MODE_AUTOMATIC = 1

const eventEmitter = new NativeEventEmitter(SystemSettingNative);

export default class SystemSetting {
    static saveBrightnessVal = -1;
    static saveScreenModeVal = SCREEN_BRIGHTNESS_MODE_AUTOMATIC;

    static async getBrightness() {
        return await SystemSettingNative.getBrightness()
    }

    static setBrightness(val) {
        SystemSettingNative.setBrightness(val)
    }

    static setBrightnessForce(val) {
        if (Utils.isAndroid) {
            SystemSetting.setScreenMode(SCREEN_BRIGHTNESS_MODE_MANUAL)
        }
        SystemSetting.setBrightness(val)
    }

    static async getScreenMode() {
        if (Utils.isAndroid) {
            return await SystemSettingNative.getScreenMode()
        }
        return -1 // cannot get iOS screen mode
    }

    static setScreenMode(val) {
        if (Utils.isAndroid) {
            SystemSettingNative.setScreenMode(val)
        }
    }

    static async saveBrightness(){
        SystemSetting.saveBrightnessVal = await SystemSetting.getBrightness()
        SystemSetting.saveScreenModeVal = await SystemSetting.getScreenMode()
    }

    static restoreBrightness(){
        if(SystemSetting.saveBrightnessVal == -1){
            console.warn('you should call saveBrightness() at least once');
        }else{
            SystemSetting.setBrightness(SystemSetting.saveBrightnessVal)
            SystemSetting.setScreenMode(SystemSetting.saveScreenModeVal)
        }
        return SystemSetting.saveBrightnessVal
    }

    static async getVolume() {
        return await SystemSettingNative.getVolume()
    }

    static setVolume(val) {
        SystemSettingNative.setVolume(val)
    }

    static addVolumeListener(callback) {
        return eventEmitter.addListener('EventVolume', callback)
    }

    static removeVolumeListener(listener){
        listener && listener.remove()
    }

    static async isWifiEnabled(){
        const result = await SystemSettingNative.isWifiEnabled()
        console.warn(result);
        return (result) > 0
    }

    static switchWifi(complete){
        SystemSettingNative.switchWifi()
        console.warn(1);
        if(Utils.isAndroid){
            complete()
        }else{
            const listener = eventEmitter.addListener('EventEnterForeground', () => {
                listener.remove()
                complete()
            })
        }
    }
}
