#= require application
#= require_self
#= require_tree .
#= require mobile/components

class MobileApplication extends TaoApplication

window.Beast = {}
Beast.app = window.app = new MobileApplication()
