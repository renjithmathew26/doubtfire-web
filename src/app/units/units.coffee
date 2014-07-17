
angular.module("doubtfire.units", [
  'doubtfire.units.partials'
]
).config(($stateProvider) ->

  $stateProvider.state("units#show",
    url: "/units?unitRole"
    views:
      main:
        controller: "UnitsShowCtrl"
        templateUrl: "units/show.tpl.html"
      header:
        controller: "BasicHeaderCtrl"
        templateUrl: "common/header.tpl.html"
      sidebar:
        controller: "BasicSidebarCtrl"
        templateUrl: "common/sidebar.tpl.html"

    data:
      pageTitle: "_Home_"
      roleWhitelist: ['basic', 'admin']
  )
  .state("admin/units#index",
    url: "/admin/units"
    views:
      main:
        controller: "AdminUnitsCtrl"
        templateUrl: "units/admin.tpl.html"
      header:
        controller: "BasicHeaderCtrl"
        templateUrl: "common/header.tpl.html"
      sidebar:
        controller: "BasicSidebarCtrl"
        templateUrl: "common/sidebar.tpl.html"
    data:
      pageTitle: "_Unit Administration_"
      roleWhitelist: ['admin']
  )
  .state("admin/units#edit",
    url: "/admin/units/edit"
    views:
      main:
        controller: "UnitCtrl"
        templateUrl: "units/unit.tpl.html"
      header:
        controller: "BasicHeaderCtrl"
        templateUrl: "common/header.tpl.html"
      sidebar:
        controller: "BasicSidebarCtrl"
        templateUrl: "common/sidebar.tpl.html"
    data:
      pageTitle: "_Unit Administration_"
      roleWhitelist: ['admin']
   )
)
.service('unitService', () ->
  unit = { id: -1 }
  staff = []
  tutors = []

  this.getUnit = ->
    return unit

  this.getStaff = ->
    return staff

  this.getTutors = ->
    return tutors

  this.setUnit = (theUnit) ->
    unit = theUnit

  this.setStaff = (theStaff) ->
    staff = theStaff

  this.setTutors = (theTutors) ->
    tutors = theTutors

  return this
)
.controller("UnitsShowCtrl", ($scope, $state, $stateParams, Unit, UnitRole, headerService, alertService, unitService) ->
  $scope.unitLoaded = false


  UnitRole.get { id: $state.params.unitRole }, (unitRole) ->
    # The user selects the unit role to view - allows multiple roles per unit
    $scope.unitRole = unitRole # the selected unit role

    # Set the roles in the header
    links = []
    if unitRole
      links.push { class: "active", url: "#/units?unitRole=" + unitRole.id, name: unitRole.role }
      
      for other_role in unitRole.other_roles
        links.push { class: "", url: "#/units?unitRole=" + other_role.id, name: other_role.role }

    headerService.setLinks( links )

    if unitRole
      Unit.get { id: unitRole.unit_id }, (unit) ->
        $scope.unit = unit # the unit related to the role
        $scope.unitLoaded = true
  # end get unit role

    
  #
  # Allow the caller to fetch a task definition from the unit based on its id
  #
  $scope.taskDef = (taskDefId) ->
    _.where $scope.unit.task_definitions, {id: taskDefId}

  #
  # Allow the caller to fetch a tutorial from the unit based on its id
  #
  $scope.tutorialFromId = (tuteId) ->
    _.where $scope.unit.tutorials, { id: tuteId }

  $scope.taskCount = () ->
    $scope.unit.task_definitions.length
)
.controller("AdminUnitsCtrl", ($scope, $state, $stateParams, $location, Unit, Convenor, Tutor,unitService) ->
  $scope.units = Unit.query()
  $scope.convenors = Convenor.query()
  tutors = _.map(Tutor.query(), (tutor) ->
    return { id: tutor.user_id, user_name: tutor.user_name }
  )
  $scope.tutors = _.uniq(tutors, (item) ->
    return item.id
  )

  $scope.showUnit = (unit) ->
    unitToShow = if unit?
      unit
    else
      new Unit { id: -1, convenors: [] }
    unitService.setUnit(unitToShow)
    unitService.setStaff($scope.convenors)
    unitService.setTutors($scope.tutors)
    $location.path('/admin/units/edit')
)
.controller('UnitCtrl', ($scope, $state, $stateParams,  $location, Unit, UnitRole,  headerService, alertService, unitService) ->

  unit = unitService.getUnit()
  staff = unitService.getStaff()
)
