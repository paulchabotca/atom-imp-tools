{WorkspaceView} = require 'atom'
MenuManager = require '../../lib/utils/menu-manager'
SettingsHelper = require '../../lib/utils/settings-helper'

describe 'MenuManager tests', ->
  activationPromise = null
  originalProfile = null

  beforeEach ->
    require '../../lib/vendor/ApiClient'

    originalProfile = SettingsHelper.getProfile()
    # For tests not to mess up our profile, we have to switch to test one...
    SettingsHelper.setProfile 'spark-ide-test'

    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('spark-ide')

  afterEach ->
    SettingsHelper.setProfile originalProfile
    delete require.cache[require.resolve('../../lib/vendor/ApiClient')]

  it 'checks menu for logged out user', ->
    waitsForPromise ->
      activationPromise

    runs ->
      ideMenu = MenuManager.getMenu()
      expect(ideMenu.submenu[0].label).toBe('Log in to Spark Cloud...')
      expect(ideMenu.submenu[0].command).toBe('spark-ide:login')


  it 'checks menu for logged in user', ->
    waitsForPromise ->
      activationPromise

    runs ->
      SettingsHelper.setCredentials 'foo@bar.baz', '0123456789abcdef0123456789abcdef'

      # Refresh UI
      atom.workspaceView.trigger 'spark-ide:update-menu'

      ideMenu = MenuManager.getMenu()

      expect(ideMenu.submenu[0].label).toBe('Log out foo@bar.baz')
      expect(ideMenu.submenu[0].command).toBe('spark-ide:logout')

      expect(ideMenu.submenu[1].type).toBe('separator')

      expect(ideMenu.submenu[2].label).toBe('Select Core...')
      expect(ideMenu.submenu[2].command).toBe('spark-ide:select-core')

      SettingsHelper.clearCredentials()

  it 'checks menu for selected core', ->
    waitsForPromise ->
      activationPromise

    runs ->
      SettingsHelper.setCredentials 'foo@bar.baz', '0123456789abcdef0123456789abcdef'
      atom.workspaceView.trigger 'spark-ide:update-menu'

      ideMenu = MenuManager.getMenu()

      expect(ideMenu.submenu.length).toBe(3)

      SettingsHelper.setCurrentCore '0123456789abcdef0123456789abcdef', 'Foo'
      atom.workspaceView.trigger 'spark-ide:update-menu'

      ideMenu = MenuManager.getMenu()

      expect(ideMenu.submenu.length).toBe(5)

      expect(ideMenu.submenu[3].label).toBe('Rename Foo...')
      expect(ideMenu.submenu[3].command).toBe('spark-ide:rename-core')

      expect(ideMenu.submenu[4].label).toBe('Remove Foo...')
      expect(ideMenu.submenu[4].command).toBe('spark-ide:remove-core')

      SettingsHelper.clearCurrentCore()
      SettingsHelper.clearCredentials()