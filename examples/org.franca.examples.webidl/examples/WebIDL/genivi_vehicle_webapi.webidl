

// dummy definitions for avoiding syntax errors
interface Event { };
interface Error { };
interface EventTarget { };
interface genivi { };


// this part has been copied from https://collab.genivi.org/wiki/display/genivi/Web+API+for+Vehicle+Data#WebAPIforVehicleData-6.FullWebIDL

module vehicle {
    typedef DOMString VehicleEventType;
     
    interface VehicleError : Error {
        const short ACCESS_DENIED = 1;
        const short NOT_AVAILABLE = 2;
        const short UNKNOWN = 0;
    };

    [NoInterfaceObject]
    interface VehicleEvent : Event {
    };
     
    [NoInterfaceObject]
    callback interface SuccessCallback {
        void onSuccess();
    };
     
    [NoInterfaceObject]
    callback interface ErrorCallback {
        void onError(VehicleError error);
    };
     
    interface VehicleDataHandler {
        void handleVehicleData(VehicleEvent data);
    };
 
    [NoInterfaceObject]
    interface Vehicle {
        readonly attribute VehicleInterface vehicle;
    };
    genivi implements Vehicle;
     
    [NoInterfaceObject]
    interface VehicleInterface : EventTarget {
        void get(VehicleEventType type, VehicleDataHandler handler, ErrorCallback errorCB);
        void set(VehicleEventType type, VehicleEvent data, SuccessCallback successCB, ErrorCallback errorCB);
        VehicleEventType[] getSupportedEventTypes(VehicleEventType type, boolean writable);
    };
     
    interface VehicleInfoEvent : VehicleEvent {
        const VehicleEventType VEHICLE_INFO = "vehicle_info";
        const VehicleEventType VEHICLE_INFO_WMI = "vehicle_info_wmi";
        const VehicleEventType VEHICLE_INFO_VIN = "vehicle_info_vin";
        const VehicleEventType VEHICLE_INFO_VEHICLE_TYPE = "vehicle_info_vehicle_type";
        const VehicleEventType VEHICLE_INFO_DOOR_TYPE = "vehicle_info_door_type";
        const VehicleEventType VEHICLE_INFO_DOOR_TYPE_1ST_ROW = "vehicle_info_door_type_1st_row";
        const VehicleEventType VEHICLE_INFO_DOOR_TYPE_2ND_ROW = "vehicle_info_door_type_2nd_row";
        const VehicleEventType VEHICLE_INFO_DOOR_TYPE_3RD_ROW = "vehicle_info_door_type_3rd_row";
        const VehicleEventType VEHICLE_INFO_FUEL_TYPE = "vehicle_info_fuel_type";
        const VehicleEventType VEHICLE_INFO_TRANSMISSION_GEAR_TYPE = "vehicle_info_transmission_gear_type";
        const VehicleEventType VEHICLE_INFO_WHEEL_INFO = "vehicle_info_wheel_info";
        const VehicleEventType VEHICLE_INFO_WHEEL_INFO_RADIUS = "vehicle_info_wheel_info_radius";
        const VehicleEventType VEHICLE_INFO_WHEEL_INFO_TRACK = "vehicle_info_wheel_info_track";
         
        const unsigned short VEHICLE_TYPE_SEDAN = 1;
        const unsigned short VEHICLE_TYPE_COUPE = 2;
        const unsigned short VEHICLE_TYPE_CABRIOLET = 3;
        const unsigned short VEHICLE_TYPE_ROADSTER = 4;
        const unsigned short VEHICLE_TYPE_SUV = 5;
        const unsigned short VEHICLE_TYPE_TRUCK = 6;
 
        const octet FUEL_TYPE_GASOLINE = 0x01;
        const octet FUEL_TYPE_METHANOL= 0x02;
        const octet FUEL_TYPE_ETHANOL = 0x03;
        const octet FUEL_TYPE_DIESEL= 0x04;
        const octet FUEL_TYPE_LPG = 0x05;
        const octet FUEL_TYPE_CNG = 0x06;
        const octet FUEL_TYPE_PROPANE = 0x07;
        const octet FUEL_TYPE_ELECTRIC = 0x08;
        const octet FUEL_TYPE_BIFUEL_RUNNING_GASOLINE = 0x09;
        const octet FUEL_TYPE_BIFUEL_RUNNING_METHANOL = 0x0A;
        const octet FUEL_TYPE_BIFUEL_RUNNING_ETHANOL = 0x0B;
        const octet FUEL_TYPE_BIFUEL_RUNNING_LPG = 0x0C;
        const octet FUEL_TYPE_BIFUEL_RUNNING_CNG = 0x0D;
        const octet FUEL_TYPE_BIFUEL_RUNNING_PROP = 0x0E;
        const octet FUEL_TYPE_BIFUEL_RUNNING_ELECTRICITY = 0x0F;
        const octet FUEL_TYPE_BIFUEL_MIXED_GAS_ELECTRIC= 0x10;
        const octet FUEL_TYPE_HYBRID_GASOLINE = 0x11;
        const octet FUEL_TYPE_HYBRID_ETHANOL = 0x12;
        const octet FUEL_TYPE_HYBRID_DIESEL = 0x13;
        const octet FUEL_TYPE_HYBRID_ELECTRIC = 0x14;
        const octet FUEL_TYPE_HYBRID_MIXED_FUEL = 0x15;
        const octet FUEL_TYPE_HYBRID_REGENERATIVE = 0x16;
         
        const unsigned short TRANSMISSION_GEAR_TYPE_AUTO = 1;
        const unsigned short TRANSMISSION_GEAR_TYPE_MANUAL = 2;
        const unsigned short TRANSMISSION_GEAR_TYPE_CVT = 3;
 
        readonly attribute VehicleEventType type;
        readonly attribute DOMString wmi;
        readonly attribute DOMString vin;
        readonly attribute unsigned short? vehicleType;
        readonly attribute unsigned short? doorType1stRow;
        readonly attribute unsigned short? doorType2ndRow;
        readonly attribute unsigned short? doorType3rdRow;
        readonly attribute octet? fuelType;
        readonly attribute unsigned short? transmissionGearType;
        readonly attribute double? wheelInfoRadius;
        readonly attribute double? wheelInfoTrack;
    };
     
    interface RunningStatusEvent : VehicleEvent {
        const VehicleEventType RUNNING_STATUS = "running_status";
        const VehicleEventType RUNNING_STATUS_VEHICLE_POWER_MODE = "running_status_vehicle_power_mode";
        const VehicleEventType RUNNING_STATUS_SPEEDOMETER = "running_status_speedometer";
        const VehicleEventType RUNNING_STATUS_ENGINE_SPEED = "running_status_engine_speed";
        const VehicleEventType RUNNING_STATUS_TRIP_METER = "running_status_trip_meter";
        const VehicleEventType RUNNING_STATUS_TRIP_METER_1 = "running_status_trip_meter_1";
        const VehicleEventType RUNNING_STATUS_TRIP_METER_2 = "running_status_trip_meter_2";
        const VehicleEventType RUNNING_STATUS_TRIP_METER_1_MILEAGE = "running_status_trip_meter_1_mileage";
        const VehicleEventType RUNNING_STATUS_TRIP_METER_2_MILEAGE = "running_status_trip_meter_2_mileage";
        const VehicleEventType RUNNING_STATUS_TRIP_METER_1_AVERAGE_SPEED = "running_status_trip_meter_1_average_speed";
        const VehicleEventType RUNNING_STATUS_TRIP_METER_2_AVERAGE_SPEED = "running_status_trip_meter_2_average_speed";
        const VehicleEventType RUNNING_STATUS_TRIP_METER_1_FUEL_CONSUMPTION = "running_status_trip_meter_1_fuel_consumption";
        const VehicleEventType RUNNING_STATUS_TRIP_METER_2_FUEL_CONSUMPTION = "running_status_trip_meter_2_fuel_consumption";
        const VehicleEventType RUNNING_STATUS_TRANSMISSION_GEAR_STATUS = "running_status_transmission_gear_status";
        const VehicleEventType RUNNING_STATUS_CRUISE_CONTROL = "running_status_cruise_control";
        const VehicleEventType RUNNING_STATUS_CRUISE_CONTROL_STATUS = "running_status_cruise_control_status";
        const VehicleEventType RUNNING_STATUS_CRUISE_CONTROL_SPEED = "running_status_cruise_control_speed";
        const VehicleEventType RUNNING_STATUS_WHEEL_BRAKE = "running_status_wheel_brake";
        const VehicleEventType RUNNING_STATUS_LIGHTS_STATUS = "running_status_lights_status";
        const VehicleEventType RUNNING_STATUS_LIGHTS_STATUS_HEAD = "running_status_lights_status_head";
        const VehicleEventType RUNNING_STATUS_LIGHTS_STATUS_HIGH_BEAM = "running_status_lights_status_high_beam";
        const VehicleEventType RUNNING_STATUS_LIGHTS_STATUS_TURN_LEFT = "running_status_lights_status_turn_left";
        const VehicleEventType RUNNING_STATUS_LIGHTS_STATUS_TURN_RIGHT = "running_status_lights_status_turn_right";
        const VehicleEventType RUNNING_STATUS_LIGHTS_STATUS_BRAKE = "running_status_lights_status_brake";
        const VehicleEventType RUNNING_STATUS_LIGHTS_STATUS_FOG_FRONT = "running_status_lights_status_fog_front";
        const VehicleEventType RUNNING_STATUS_LIGHTS_STATUS_FOG_REAR = "running_status_lights_status_fog_rear";
        const VehicleEventType RUNNING_STATUS_LIGHTS_STATUS_HAZARD = "running_status_lights_status_hazard";
        const VehicleEventType RUNNING_STATUS_LIGHTS_STATUS_PARKING = "running_status_lights_status_parking";
        const VehicleEventType RUNNING_STATUS_INTERIOR_LIGHTS_STATUS = "running_status_interior_lights_status";
        const VehicleEventType RUNNING_STATUS_INTERIOR_LIGHTS_STATUS_DRIVER = "running_status_interior_lights_status_driver";
        const VehicleEventType RUNNING_STATUS_INTERIOR_LIGHTS_STATUS_PASSENGER = "running_status_interior_lights_status_passenger";
        const VehicleEventType RUNNING_STATUS_INTERIOR_LIGHTS_STATUS_CENTER = "running_status_interior_lights_status_center";
        const VehicleEventType RUNNING_STATUS_AUTOMATIC_HEADLIGHTS = "running_status_automatic_headlights";
        const VehicleEventType RUNNING_STATUS_DYNAMIC_HIGH_BEAM = "running_status_dynamic_high_beam";
        const VehicleEventType RUNNING_STATUS_HORN = "running_status_horn";
        const VehicleEventType RUNNING_STATUS_CHIME = "running_status_chime";
        const VehicleEventType RUNNING_STATUS_FUEL = "running_status_fuel";
        const VehicleEventType RUNNING_STATUS_ESTIMATED_RANGE = "running_status_estimated_range";
        const VehicleEventType RUNNING_STATUS_ENGINE_OIL = "running_status_engine_oil";
        const VehicleEventType RUNNING_STATUS_ENGINE_OIL_REMAINING = "running_status_engine_oil_remaining";
        const VehicleEventType RUNNING_STATUS_ENGINE_OIL_CHANGE = "running_status_engine_oil_change";
        const VehicleEventType RUNNING_STATUS_ENGINE_OIL_TEMP = "running_status_engine_oil_temp";
        const VehicleEventType RUNNING_STATUS_ENGINE_COOLANT = "running_status_engine_coolant";
        const VehicleEventType RUNNING_STATUS_ENGINE_COOLANT_LEVEL = "running_status_engine_coolant_level";
        const VehicleEventType RUNNING_STATUS_ENGINE_COOLANT_TEMP = "running_status_engine_coolant_temp";
        const VehicleEventType RUNNING_STATUS_STEERING_WHEEL_ANGLE = "running_status_steering_wheel_angle";
         
        const unsigned short VEHICLE_POWER_MODE_OFF = 1;
        const unsigned short VEHICLE_POWER_MODE_ACC = 2;
        const unsigned short VEHICLE_POWER_MODE_RUN = 3;
        const unsigned short VEHICLE_POWER_MODE_IGNITION = 4;
         
        const unsigned short TRANSMISSION_GEAR_STATUS_NEUTRAL = 0;
        const unsigned short TRANSMISSION_GEAR_STATUS_MANUAL_1 = 1;
        const unsigned short TRANSMISSION_GEAR_STATUS_MANUAL_2 = 2;
        const unsigned short TRANSMISSION_GEAR_STATUS_MANUAL_3 = 3;
        const unsigned short TRANSMISSION_GEAR_STATUS_MANUAL_4 = 4;
        const unsigned short TRANSMISSION_GEAR_STATUS_MANUAL_5 = 5;
        const unsigned short TRANSMISSION_GEAR_STATUS_MANUAL_6 = 6;
        const unsigned short TRANSMISSION_GEAR_STATUS_MANUAL_7 = 7;
        const unsigned short TRANSMISSION_GEAR_STATUS_MANUAL_8 = 8;
        const unsigned short TRANSMISSION_GEAR_STATUS_MANUAL_9 = 9;
        const unsigned short TRANSMISSION_GEAR_STATUS_MANUAL_10 = 10;
        const unsigned short TRANSMISSION_GEAR_STATUS_AUTO_1 = 11;
        const unsigned short TRANSMISSION_GEAR_STATUS_AUTO_2 = 12;
        const unsigned short TRANSMISSION_GEAR_STATUS_AUTO_3 = 13;
        const unsigned short TRANSMISSION_GEAR_STATUS_AUTO_4 = 14;
        const unsigned short TRANSMISSION_GEAR_STATUS_AUTO_5 = 15;
        const unsigned short TRANSMISSION_GEAR_STATUS_AUTO_6 = 16;
        const unsigned short TRANSMISSION_GEAR_STATUS_AUTO_7 = 17;
        const unsigned short TRANSMISSION_GEAR_STATUS_AUTO_8 = 18;
        const unsigned short TRANSMISSION_GEAR_STATUS_AUTO_9 = 19;
        const unsigned short TRANSMISSION_GEAR_STATUS_AUTO_10 = 20;
        const unsigned short TRANSMISSION_GEAR_STATUS_DRIVE = 32;
        const unsigned short TRANSMISSION_GEAR_STATUS_PARKING = 64;
        const unsigned short TRANSMISSION_GEAR_STATUS_REVERSE = 128;
         
        const unsigned short WHEEL_BRAKE_IDLE = 1;
        const unsigned short WHEEL_BRAKE_ENGAGED = 2;
        const unsigned short WHEEL_BRAKE_MALFUNCTION = 3;
         
        const unsigned short ENGINE_COOLANT_LEVEL_NORMAL = 0;
        const unsigned short ENGINE_COOLANT_LEVEL_LOW = 1;
         
        readonly attribute VehicleEventType type;
        readonly attribute unsigned short? vehiclePowerMode;
        readonly attribute unsigned short speedometer;
        readonly attribute unsigned short? engineSpeed;
        readonly attribute unsigned long? tripMeter1Mileage;
        readonly attribute unsigned long? tripMeter2Mileage;
        readonly attribute unsigned short? tripMeter1AverageSpeed;
        readonly attribute unsigned short? tripMeter2AverageSpeed;
        readonly attribute unsigned long? tripMeter1FuelConsumption;
        readonly attribute unsigned long? tripMeter2FuelConsumption;
        readonly attribute unsigned short? transmissionGearStatus;
        readonly attribute boolean? cruiseControlStatus;
        readonly attribute unsigned short? cruiseControlSpeed;
        readonly attribute unsigned short? wheelBrake;
        readonly attribute boolean? lightsStatusHead;
        readonly attribute boolean? lightsStatusHighBeam;
        readonly attribute boolean? lightsStatusTurnLeft;
        readonly attribute boolean? lightsStatusTurnRight;
        readonly attribute boolean? lightsStatusBrake;
        readonly attribute boolean? lightsStatusFogFront;
        readonly attribute boolean? lightsStatusFogRear;
        readonly attribute boolean? lightsStatusHazard;
        readonly attribute boolean? lightsStatusParking;
        readonly attribute boolean? interiorLightsStatusDriver;
        readonly attribute boolean? interiorLightsStatusPassenger;
        readonly attribute boolean? interiorLightsStatusCenter;
        readonly attribute boolean? automaticHeadlights;
        readonly attribute boolean? dynamicHighBeam;
        readonly attribute boolean? horn;
        readonly attribute boolean? chime;
        readonly attribute unsigned short fuel;
        readonly attribute unsigned long? estimatedRange;
        readonly attribute unsigned short? engineOilRemaining;
        readonly attribute boolean? engineOilChange;
        readonly attribute short? engineOilTemp;
        readonly attribute unsigned short? engineCoolantLevel;
        readonly attribute short? engineCoolantTemp;
        readonly attribute short? steeringWheelAngle;
    };
     
    interface MaintenanceEvent : VehicleEvent {
        const VehicleEventType MAINTENANCE = "maintenance";
        const VehicleEventType MAINTENANCE_ODOMETER = "maintenance_odometer";
        const VehicleEventType MAINTENANCE_TRANSMISSION_OIL = "maintenance_transmission_oil";
        const VehicleEventType MAINTENANCE_TRANSMISSION_OIL_LIFE_LEVEL = "maintenance_transmission_oil_life_level";
        const VehicleEventType MAINTENANCE_TRANSMISSION_OIL_TEMP = "maintenance_transmission_oil_temp";
        const VehicleEventType MAINTENANCE_BRAKE_FLUID_LEVEL = "maintenance_brake_fluid_level";
        const VehicleEventType MAINTENANCE_WASHER_FLUID_LEVEL = "maintenance_washer_fluid_level";
        const VehicleEventType MAINTENANCE_MALFUNCTION_INDICATOR_LAMP = "maintenance_malfunction_indicator_lamp";
        const VehicleEventType MAINTENANCE_BATTERY = "maintenance_battery";
        const VehicleEventType MAINTENANCE_BATTERY_VOLTAGE = "maintenance_battery_voltage";
        const VehicleEventType MAINTENANCE_BATTERY_CURRENT = "maintenance_battery_current";
        const VehicleEventType MAINTENANCE_TIRE_PRESSURE = "maintenance_tire_pressure";
        const VehicleEventType MAINTENANCE_TIRE_PRESSURE_FRONT_LEFT = "maintenance_tire_pressure_front_left";
        const VehicleEventType MAINTENANCE_TIRE_PRESSURE_FRONT_RIGHT = "maintenance_tire_pressure_front_right";
        const VehicleEventType MAINTENANCE_TIRE_PRESSURE_REAR_LEFT = "maintenance_tire_pressure_rear_left";
        const VehicleEventType MAINTENANCE_TIRE_PRESSURE_REAR_RIGHT = "maintenance_tire_pressure_rear_right";
        const VehicleEventType MAINTENANCE_TIRE_PRESSURE_STATUS = "maintenance_tire_pressure_status";
        const VehicleEventType MAINTENANCE_TIRE_PRESSURE_STATUS_FRONT_LEFT = "maintenance_tire_pressure_status_front_left";
        const VehicleEventType MAINTENANCE_TIRE_PRESSURE_STATUS_FRONT_RIGHT = "maintenance_tire_pressure_status_front_right";
        const VehicleEventType MAINTENANCE_TIRE_PRESSURE_STATUS_REAR_LEFT = "maintenance_tire_pressure_status_rear_left";
        const VehicleEventType MAINTENANCE_TIRE_PRESSURE_STATUS_REAR_RIGHT = "maintenance_tire_pressure_status_rear_right";
         
        const unsigned short TIRE_PRESSURE_STATUS_NORMAL = 0;
        const unsigned short TIRE_PRESSURE_STATUS_LOW = 1;
        const unsigned short TIRE_PRESSURE_STATUS_HIGH = 2;
     
        readonly attribute VehicleEventType type;
        readonly attribute unsigned long odometer;
        readonly attribute boolean? transmissionOilLifeLevel;
        readonly attribute short? transmissionOilTemp;
        readonly attribute boolean? brakeFluidLevel;
        readonly attribute boolean? washerFluidLevel;
        readonly attribute boolean? malfunctionIndicatorLamp;
        readonly attribute unsigned short? batteryVoltage;
        readonly attribute unsigned short? batteryCurrent;
        readonly attribute unsigned short? tirePressureFrontLeft;
        readonly attribute unsigned short? tirePressureFrontRight;
        readonly attribute unsigned short? tirePressureRearLeft;
        readonly attribute unsigned short? tirePressureRearRight;
        readonly attribute unsigned short? tirePressureStatusFrontLeft;
        readonly attribute unsigned short? tirePressureStatusFrontRight;
        readonly attribute unsigned short? tirePressureStatusRearLeft;
        readonly attribute unsigned short? tirePressureStatusRearRight;
    };
     
    interface PersonalizationEvent : VehicleEvent {
        const VehicleEventType PERSONALIZATION = "personalization";
        const VehicleEventType PERSONALIZATION_KEY_ID = "personalization_key_id";
        const VehicleEventType PERSONALIZATION_LANGUAGE = "personalization_language";
        const VehicleEventType PERSONALIZATION_MEASUREMENT_SYSTEM = "personalization_measurement_system";
        const VehicleEventType PERSONALIZATION_MEASUREMENT_SYSTEM_STRING = "personalization_measurement_system_string";
        const VehicleEventType PERSONALIZATION_MEASUREMENT_SYSTEM_STRING_FUEL = "personalization_measurement_system_string_fuel";
        const VehicleEventType PERSONALIZATION_MEASUREMENT_SYSTEM_STRING_DISTANCE = "personalization_measurement_system_string_distance";
        const VehicleEventType PERSONALIZATION_MEASUREMENT_SYSTEM_STRING_SPEED = "personalization_measurement_system_string_speed";
        const VehicleEventType PERSONALIZATION_MEASUREMENT_SYSTEM_STRING_CONSUMPTION = "personalization_measurement_system_string_consumption";
        const VehicleEventType PERSONALIZATION_MIRROR = "personalization_mirror";
        const VehicleEventType PERSONALIZATION_MIRROR_DRIVER = "personalization_mirror_driver";
        const VehicleEventType PERSONALIZATION_MIRROR_PASSENGER = "personalization_mirror_passenger";
        const VehicleEventType PERSONALIZATION_MIRROR_INSIDE = "personalization_mirror_inside";
        const VehicleEventType PERSONALIZATION_STEERING_WHEEL_POSITION = "personalization_steering_wheel_position";
        const VehicleEventType PERSONALIZATION_STEERING_WHEEL_POSITION_SLIDE = "personalization_steering_wheel_position_slide";
        const VehicleEventType PERSONALIZATION_STEERING_WHEEL_POSITION_TILT = "personalization_steering_wheel_position_tilt";
        const VehicleEventType PERSONALIZATION_DRIVING_MODE = "personalization_driving_mode";
        const VehicleEventType PERSONALIZATION_DRIVER_SEAT_POSITION = "personalization_driver_seat_position";
        const VehicleEventType PERSONALIZATION_DRIVER_SEAT_POSITION_RECLINE_SEATBACK = "personalization_driver_seat_position_recline_seatback";
        const VehicleEventType PERSONALIZATION_DRIVER_SEAT_POSITION_SLIDE = "personalization_driver_seat_position_slide";
        const VehicleEventType PERSONALIZATION_DRIVER_SEAT_POSITION_CUSHION_HEIGHT = "personalization_driver_seat_position_cushion_height";
        const VehicleEventType PERSONALIZATION_DRIVER_SEAT_POSITION_HEADREST = "personalization_driver_seat_position_headrest";
        const VehicleEventType PERSONALIZATION_DRIVER_SEAT_POSITION_BACK_CUSHION = "personalization_driver_seat_position_back_cushion";
        const VehicleEventType PERSONALIZATION_DRIVER_SEAT_POSITION_SIDE_CUSHION = "personalization_driver_seat_position_side_cushion";
        const VehicleEventType PERSONALIZATION_PASSENGER_SEAT_POSITION = "personalization_passenger_seat_position";
        const VehicleEventType PERSONALIZATION_PASSENGER_SEAT_POSITION_RECLINE_SEATBACK = "personalization_passenger_seat_position_recline_seatback";
        const VehicleEventType PERSONALIZATION_PASSENGER_SEAT_POSITION_SLIDE = "personalization_passenger_seat_position_slide";
        const VehicleEventType PERSONALIZATION_PASSENGER_SEAT_POSITION_CUSHION_HEIGHT = "personalization_passenger_seat_position_cushion_height";
        const VehicleEventType PERSONALIZATION_PASSENGER_SEAT_POSITION_HEADREST = "personalization_passenger_seat_position_headrest";
        const VehicleEventType PERSONALIZATION_PASSENGER_SEAT_POSITION_BACK_CUSHION = "personalization_passenger_seat_position_back_cushion";
        const VehicleEventType PERSONALIZATION_PASSENGER_SEAT_POSITION_SIDE_CUSHION = "personalization_passenger_seat_position_side_cushion";
        const VehicleEventType PERSONALIZATION_DASHBOARD_ILLUMINATION = "personalization_dashboard_illumination";
        const VehicleEventType PERSONALIZATION_GENERATED_VEHICLE_SOUND_MODE = "personalization_generated_vehicle_sound_mode";
         
        const unsigned short LANGUAGE_ENGLISH = 1;
        const unsigned short LANGUAGE_SPANISH = 2;
        const unsigned short LANGUAGE_FRENCH = 3;
         
        const unsigned short DRIVING_MODE_COMFORT = 1;
        const unsigned short DRIVING_MODE_AUTO = 2;
        const unsigned short DRIVING_MODE_SPORT = 3;
        const unsigned short DRIVING_MODE_ECO = 4;
        const unsigned short DRIVING_MODE_MANUAL = 5;
         
        const unsigned short GENERATED_VEHICLE_SOUND_MODE_NORMAL = 1;
        const unsigned short GENERATED_VEHICLE_SOUND_MODE_QUIET = 2;
        const unsigned short GENERATED_VEHICLE_SOUND_MODE_SPORTIVE = 3;
         
        readonly attribute VehicleEventType type;
        readonly attribute DOMString? keyId;
        readonly attribute unsigned short? language;
        readonly attribute boolean? measurementSystem;
        readonly attribute DOMString? measurementSystemStringFuel;
        readonly attribute DOMString? measurementSystemStringDistance;
        readonly attribute DOMString? measurementSystemStringSpeed;
        readonly attribute DOMString? measurementSystemStringConsumption;
        readonly attribute unsigned short? mirrorDriver;
        readonly attribute unsigned short? mirrorPassenger;
        readonly attribute unsigned short? mirrorInside;
        readonly attribute unsigned short? steeringWheelPositionSlide;
        readonly attribute unsigned short? steeringWheelPositionTilt;
        readonly attribute unsigned short? drivingMode;
        readonly attribute unsigned short? driverSeatPositionReclineSeatback;
        readonly attribute unsigned short? driverSeatPositionSlide;
        readonly attribute unsigned short? driverSeatPositionCushionHeight;
        readonly attribute unsigned short? driverSeatPositionHeadrest;
        readonly attribute unsigned short? driverSeatPositionBackCushion;
        readonly attribute unsigned short? driverSeatPositionSideCushion;
        readonly attribute unsigned short? passengerSeatPositionReclineSeatback;
        readonly attribute unsigned short? passengerSeatPositionSlide;
        readonly attribute unsigned short? passengerSeatPositionCushionHeight;
        readonly attribute unsigned short? passengerSeatPositionHeadrest;
        readonly attribute unsigned short? passengerSeatPositionBackCushion;
        readonly attribute unsigned short? passengerSeatPositionSideCushion;
        readonly attribute unsigned short? dashboardIllumination;
        readonly attribute unsigned short? generatedVehicleSoundMode;
    };
     
    interface DrivingSafetyEvent : VehicleEvent {
        const VehicleEventType DRIVING_SAFETY = "driving_safety";
        const VehicleEventType DRIVING_SAFETY_ANTILOCK_BRAKING_SYSTEM = "driving_safety_antilock_braking_system";
        const VehicleEventType DRIVING_SAFETY_TRACTION_CONTROL_SYSTEM = "driving_safety_traction_control_system";
        const VehicleEventType DRIVING_SAFETY_ELECTRONIC_STABILITY_CONTROL = "driving_safety_electronic_stability_control";
        const VehicleEventType DRIVING_SAFETY_VEHICLE_TOP_SPEED_LIMIT = "driving_safety_vehicle_top_speed_limit";
        const VehicleEventType DRIVING_SAFETY_AIRBAG_STATUS = "driving_safety_airbag_status";
        const VehicleEventType DRIVING_SAFETY_AIRBAG_STATUS_DRIVER = "driving_safety_airbag_status_driver";
        const VehicleEventType DRIVING_SAFETY_AIRBAG_STATUS_PASSENGER = "driving_safety_airbag_status_passenger";
        const VehicleEventType DRIVING_SAFETY_AIRBAG_STATUS_SIDE = "driving_safety_airbag_status_side";
        const VehicleEventType DRIVING_SAFETY_DOOR_OPEN_STATUS = "driving_safety_door_open_status";
        const VehicleEventType DRIVING_SAFETY_DOOR_OPEN_STATUS_DRIVER = "driving_safety_door_open_status_driver";
        const VehicleEventType DRIVING_SAFETY_DOOR_OPEN_STATUS_PASSENGER = "driving_safety_door_open_status_passenger";
        const VehicleEventType DRIVING_SAFETY_DOOR_OPEN_STATUS_REAR_LEFT = "driving_safety_door_open_status_rear_left";
        const VehicleEventType DRIVING_SAFETY_DOOR_OPEN_STATUS_REAR_RIGHT = "driving_safety_door_open_status_rear_right";
        const VehicleEventType DRIVING_SAFETY_DOOR_OPEN_STATUS_TRUNK = "driving_safety_door_open_status_trunk";
        const VehicleEventType DRIVING_SAFETY_DOOR_OPEN_STATUS_FUEL_FILTER_CAP = "driving_safety_door_open_status_fuel_filter_cap";
        const VehicleEventType DRIVING_SAFETY_DOOR_OPEN_STATUS_HOOD = "driving_safety_door_open_status_hood";
        const VehicleEventType DRIVING_SAFETY_DOOR_LOCK_STATUS = "driving_safety_door_lock_status";
        const VehicleEventType DRIVING_SAFETY_DOOR_LOCK_STATUS_DRIVER = "driving_safety_door_lock_status_driver";
        const VehicleEventType DRIVING_SAFETY_DOOR_LOCK_STATUS_PASSENGER = "driving_safety_door_lock_status_passenger";
        const VehicleEventType DRIVING_SAFETY_DOOR_LOCK_STATUS_REAR_LEFT = "driving_safety_door_lock_status_rear_left";
        const VehicleEventType DRIVING_SAFETY_DOOR_LOCK_STATUS_REAR_RIGHT = "driving_safety_door_lock_status_rear_right";
        const VehicleEventType DRIVING_SAFETY_CHILD_SAFETY_LOCK = "driving_safety_child_safety_lock";
        const VehicleEventType DRIVING_SAFETY_OCCUPANTS_STATUS = "driving_safety_occupants_status";
        const VehicleEventType DRIVING_SAFETY_OCCUPANTS_STATUS_DRIVER = "driving_safety_occupants_status_driver";
        const VehicleEventType DRIVING_SAFETY_OCCUPANTS_STATUS_PASSENGER = "driving_safety_occupants_status_passenger";
        const VehicleEventType DRIVING_SAFETY_OCCUPANTS_STATUS_REAR_LEFT = "driving_safety_occupants_status_rear_left";
        const VehicleEventType DRIVING_SAFETY_OCCUPANTS_STATUS_REAR_RIGHT = "driving_safety_occupants_status_rear_right";
        const VehicleEventType DRIVING_SAFETY_SEAT_BELT = "driving_safety_seat_belt";
        const VehicleEventType DRIVING_SAFETY_SEAT_BELT_DRIVER = "driving_safety_seat_belt_driver";
        const VehicleEventType DRIVING_SAFETY_SEAT_BELT_PASSENGER = "driving_safety_seat_belt_passenger";
        const VehicleEventType DRIVING_SAFETY_SEAT_BELT_REAR_LEFT = "driving_safety_seat_belt_rear_left";
        const VehicleEventType DRIVING_SAFETY_SEAT_BELT_REAR_RIGHT = "driving_safety_seat_belt_rear_right";
        const VehicleEventType DRIVING_SAFETY_WINDOW_LOCK = "driving_safety_window_lock";
        const VehicleEventType DRIVING_SAFETY_WINDOW_LOCK_DRIVER = "driving_safety_window_lock_driver";
        const VehicleEventType DRIVING_SAFETY_WINDOW_LOCK_PASSENGER = "driving_safety_window_lock_passenger";
        const VehicleEventType DRIVING_SAFETY_WINDOW_LOCK_REAR_LEFT = "driving_safety_window_lock_rear_left";
        const VehicleEventType DRIVING_SAFETY_WINDOW_LOCK_REAR_RIGHT = "driving_safety_window_lock_rear_right";
        const VehicleEventType DRIVING_SAFETY_OBSTACLE_DISTANCE = "driving_safety_obstacle_distance";
        const VehicleEventType DRIVING_SAFETY_OBSTACLE_DISTANCE_SENSOR_STATUS = "driving_safety_obstacle_distance_sensor_status";
        const VehicleEventType DRIVING_SAFETY_OBSTACLE_DISTANCE_FRONT_CENTER = "driving_safety_obstacle_distance_front_center";
        const VehicleEventType DRIVING_SAFETY_OBSTACLE_DISTANCE_REAR_CENTER = "driving_safety_obstacle_distance_rear_center";
        const VehicleEventType DRIVING_SAFETY_OBSTACLE_DISTANCE_FRONT_LEFT = "driving_safety_obstacle_distance_front_left";
        const VehicleEventType DRIVING_SAFETY_OBSTACLE_DISTANCE_FRONT_RIGHT = "driving_safety_obstacle_distance_front_right";
        const VehicleEventType DRIVING_SAFETY_OBSTACLE_DISTANCE_MIDDLE_LEFT = "driving_safety_obstacle_distance_middle_left";
        const VehicleEventType DRIVING_SAFETY_OBSTACLE_DISTANCE_MIDDLE_RIGHT = "driving_safety_obstacle_distance_middle_right";
        const VehicleEventType DRIVING_SAFETY_OBSTACLE_DISTANCE_REAR_LEFT = "driving_safety_obstacle_distance_rear_left";
        const VehicleEventType DRIVING_SAFETY_OBSTACLE_DISTANCE_REAR_RIGHT = "driving_safety_obstacle_distance_rear_right";
        const VehicleEventType DRIVING_SAFETY_FRONT_COLLISION_DETECTION = "driving_safety_front_collision_detection";
        const VehicleEventType DRIVING_SAFETY_FRONT_COLLISION_DETECTION_STATUS = "driving_safety_front_collision_detection_status";
        const VehicleEventType DRIVING_SAFETY_FRONT_COLLISION_DETECTION_DISTANCE = "driving_safety_front_collision_detection_distance";
        const VehicleEventType DRIVING_SAFETY_FRONT_COLLISION_DETECTION_TIME = "driving_safety_front_collision_detection_time";
     
        const unsigned short ANTILOCK_BRAKING_SYSTEM_AVAILABLE = 1;
        const unsigned short ANTILOCK_BRAKING_SYSTEM_IDLE = 2;
        const unsigned short ANTILOCK_BRAKING_SYSTEM_ENGAGED = 3;
         
        const unsigned short TRACTION_CONTROL_SYSTEM_AVAILABLE = 1;
        const unsigned short TRACTION_CONTROL_SYSTEM_IDLE = 2;
        const unsigned short TRACTION_CONTROL_SYSTEM_ENGAGED = 3;
         
        const unsigned short ELECTRONIC_STABILITY_CONTROL_AVAILABLE = 1;
        const unsigned short ELECTRONIC_STABILITY_CONTROL_IDLE = 2;
        const unsigned short ELECTRONIC_STABILITY_CONTROL_ENGAGED = 3;
         
        const unsigned short AIRBAG_STATUS_ACTIVATE = 1;
        const unsigned short AIRBAG_STATUS_DEACTIVATE = 2;
        const unsigned short AIRBAG_STATUS_DEPLOYMENT = 3;
     
        const unsigned short DOOR_OPEN_STATUS_OPEN = 1;
        const unsigned short DOOR_OPEN_STATUS_AJAR = 2;
        const unsigned short DOOR_OPEN_STATUS_CLOSE = 3;
         
        const unsigned short OCCUPANTS_STATUS_ADULT = 1;
        const unsigned short OCCUPANTS_STATUS_CHILD = 2;
        const unsigned short OCCUPANTS_STATUS_VACANT = 3;
     
        readonly attribute VehicleEventType type;
        readonly attribute unsigned short? antilockBrakingSystem;
        readonly attribute unsigned short? tractionControlSystem;
        readonly attribute unsigned short? electronicStabilityControl;
        readonly attribute unsigned short? vehicleTopSpeedLimit;
        readonly attribute unsigned short? airbagStatusDriver;
        readonly attribute unsigned short? airbagStatusPassenger;
        readonly attribute unsigned short? airbagStatusSide;
        readonly attribute unsigned short? doorOpenStatusDriver;
        readonly attribute unsigned short? doorOpenStatusPassenger;
        readonly attribute unsigned short? doorOpenStatusRearLeft;
        readonly attribute unsigned short? doorOpenStatusRearRight;
        readonly attribute unsigned short? doorOpenStatusTrunk;
        readonly attribute unsigned short? doorOpenStatusFuelFilterCap;
        readonly attribute unsigned short? doorOpenStatusHood;
        readonly attribute boolean? doorLockStatusDriver;
        readonly attribute boolean? doorLockStatusPassenger;
        readonly attribute boolean? doorLockStatusRearLeft;
        readonly attribute boolean? doorLockStatusRearRight;
        readonly attribute boolean? childSafetyLock;
        readonly attribute unsigned short? occupantsStatusDriver;
        readonly attribute unsigned short? occupantsStatusPassenger;
        readonly attribute unsigned short? occupantsStatusRearLeft;
        readonly attribute unsigned short? occupantsStatusRearRight;
        readonly attribute boolean? seatBeltDriver;
        readonly attribute boolean? seatBeltPassenger;
        readonly attribute boolean? seatBeltRearLeft;
        readonly attribute boolean? seatBeltRearRight;
        readonly attribute boolean? windowLockDriver;
        readonly attribute boolean? windowLockPassenger;
        readonly attribute boolean? windowLockRearLeft;
        readonly attribute boolean? windowLockRearRight;
        readonly attribute boolean? obstacleDistanceSensorStatus;
        readonly attribute unsigned short? obstacleDistanceFrontCenter;
        readonly attribute unsigned short? obstacleDistanceRearCenter;
        readonly attribute unsigned short? obstacleDistanceFrontLeft;
        readonly attribute unsigned short? obstacleDistanceFrontRight;
        readonly attribute unsigned short? obstacleDistanceMiddleLeft;
        readonly attribute unsigned short? obstacleDistanceMiddleRight;
        readonly attribute unsigned short? obstacleDistanceRearLeft;
        readonly attribute unsigned short? obstacleDistanceRearRight;
        readonly attribute boolean? frontCollisionDetectionStatus;
        readonly attribute unsigned long? frontCollisionDetectionDistance;
        readonly attribute unsigned long? frontCollisionDetectionTime;
    };
     
    interface VisionSystemEvent : VehicleEvent {
        const VehicleEventType VISION_SYSTEM = "vision_system";
        const VehicleEventType VISION_SYSTEM_LANE_DEPARTURE_DETECTION_STATUS = "vision_system_lane_departure_detection_status";
        const VehicleEventType VISION_SYSTEM_LANE_DEPARTED = "vision_system_lane_departed";
     
        readonly attribute VehicleEventType type;
        readonly attribute boolean? laneDepartureDetectionStatus;
        readonly attribute boolean? laneDeparted;
    };
     
    interface ParkingEvent : VehicleEvent {
        const VehicleEventType PARKING = "parking";
        const VehicleEventType PARKING_SECURITY_ALERT = "parking_security_alert";
        const VehicleEventType PARKING_PARKING_BRAKE = "parking_parking_brake";
        const VehicleEventType PARKING_PARKING_LIGHTS = "parking_parking_lights";
         
        const unsigned short SECURITY_ALERT_AVAILABLE = 1;
        const unsigned short SECURITY_ALERT_IDLE = 2;
        const unsigned short SECURITY_ALERT_ACTIVATED = 3;
        const unsigned short SECURITY_ALERT_ALARM_DETECTED = 4;
     
        readonly attribute VehicleEventType type;
        readonly attribute unsigned short? securityAlert;
        readonly attribute boolean? parkingBrake;
        readonly attribute boolean? parkingLights;
    };
     
    interface ClimateEnvironmentEvent : VehicleEvent {
        const VehicleEventType CLIMATE_ENVIRONMENT = "climate_environment";
        const VehicleEventType CLIMATE_ENVIRONMENT_INTERIOR_TEMP = "climate_environment_interior_temp";
        const VehicleEventType CLIMATE_ENVIRONMENT_EXTERIOR_TEMP = "climate_environment_exterior_temp";
        const VehicleEventType CLIMATE_ENVIRONMENT_EXTERIOR_BRIGHTNESS = "climate_environment_exterior_brightness";
        const VehicleEventType CLIMATE_ENVIRONMENT_RAIN_SENSOR = "climate_environment_rain_sensor";
        const VehicleEventType CLIMATE_ENVIRONMENT_WINDSHIELD_WIPER = "climate_environment_windshield_wiper";
        const VehicleEventType CLIMATE_ENVIRONMENT_REAR_WIPER = "climate_environment_rear_wiper";
        const VehicleEventType CLIMATE_ENVIRONMENT_HVAC_FAN = "climate_environment_hvac_fan";
        const VehicleEventType CLIMATE_ENVIRONMENT_HVAC_FAN_DIRECTION = "climate_environment_hvac_fan_direction";
        const VehicleEventType CLIMATE_ENVIRONMENT_HVAC_FAN_SPEED = "climate_environment_hvac_fan_speed";
        const VehicleEventType CLIMATE_ENVIRONMENT_HVAC_FAN_TARGET_TEMP = "climate_environment_hvac_fan_target_temp";
        const VehicleEventType CLIMATE_ENVIRONMENT_AIR_CONDITIONING = "climate_environment_air_conditioning";
        const VehicleEventType CLIMATE_ENVIRONMENT_AIR_RECIRCULATION = "climate_environment_air_recirculation";
        const VehicleEventType CLIMATE_ENVIRONMENT_HEATER = "climate_environment_heater";
        const VehicleEventType CLIMATE_ENVIRONMENT_DEFROST = "climate_environment_defrost";
        const VehicleEventType CLIMATE_ENVIRONMENT_DEFROST_WINDSHIELD = "climate_environment_defrost_windshield";
        const VehicleEventType CLIMATE_ENVIRONMENT_DEFROST_REAR_WINDOW = "climate_environment_defrost_rear_window";
        const VehicleEventType CLIMATE_ENVIRONMENT_DEFROST_SIDE_MIRRORS = "climate_environment_defrost_side_mirrors";
        const VehicleEventType CLIMATE_ENVIRONMENT_STEERING_WHEEL_HEATER = "climate_environment_steering_wheel_heater";
        const VehicleEventType CLIMATE_ENVIRONMENT_SEAT_HEATER = "climate_environment_seat_heater";
        const VehicleEventType CLIMATE_ENVIRONMENT_SEAT_COOLER = "climate_environment_seat_cooler";
        const VehicleEventType CLIMATE_ENVIRONMENT_WINDOW = "climate_environment_window";
        const VehicleEventType CLIMATE_ENVIRONMENT_WINDOW_DRIVER = "climate_environment_window_driver";
        const VehicleEventType CLIMATE_ENVIRONMENT_WINDOW_PASSENGER = "climate_environment_window_passenger";
        const VehicleEventType CLIMATE_ENVIRONMENT_WINDOW_REAR_LEFT = "climate_environment_window_rear_left";
        const VehicleEventType CLIMATE_ENVIRONMENT_WINDOW_REAR_RIGHT = "climate_environment_window_rear_right";
        const VehicleEventType CLIMATE_ENVIRONMENT_SUNROOF = "climate_environment_sunroof";
        const VehicleEventType CLIMATE_ENVIRONMENT_SUNROOF_OPENNESS = "climate_environment_sunroof_openness";
        const VehicleEventType CLIMATE_ENVIRONMENT_SUNROOF_TILT = "climate_environment_sunroof_tilt";
        const VehicleEventType CLIMATE_ENVIRONMENT_CONVERTIBLE_ROOF = "climate_environment_convertible_roof";
         
        const unsigned short RAIN_SENSOR_NO_RAIN = 0;
        const unsigned short RAIN_SENSOR_LEVEL_1 = 1;
        const unsigned short RAIN_SENSOR_LEVEL_2 = 2;
        const unsigned short RAIN_SENSOR_LEVEL_3 = 3;
        const unsigned short RAIN_SENSOR_LEVEL_4 = 4;
        const unsigned short RAIN_SENSOR_LEVEL_5 = 5;
        const unsigned short RAIN_SENSOR_LEVEL_6 = 6;
        const unsigned short RAIN_SENSOR_LEVEL_7 = 7;
        const unsigned short RAIN_SENSOR_LEVEL_8 = 8;
        const unsigned short RAIN_SENSOR_LEVEL_9 = 9;
        const unsigned short RAIN_SENSOR_HEAVIEST_RAIN = 10;
         
        const unsigned short WIPER_OFF = 0;
        const unsigned short WIPER_ONCE = 1;
        const unsigned short WIPER_SLOWEST = 2;
        const unsigned short WIPER_SLOW = 3;
        const unsigned short WIPER_FAST = 4;
        const unsigned short WIPER_FASTEST = 5;
        const unsigned short WIPER_AUTO = 10;
         
        const unsigned short HVAC_FAN_DIRECTION_FRONT_PANEL = 1;
        const unsigned short HVAC_FAN_DIRECTION_FLOOR_DUCT = 2;
        const unsigned short HVAC_FAN_DIRECTION_FRONT_FLOOR = 3;
        const unsigned short HVAC_FAN_DIRECTION_DEFROSTER_FLOOR = 4;
     
        readonly attribute VehicleEventType type;
        readonly attribute short? interiorTemp;
        readonly attribute short? exteriorTemp;
        readonly attribute unsigned long? exteriorBrightness;
        readonly attribute unsigned short? rainSensor;
        readonly attribute unsigned short? windshieldWiper;
        readonly attribute unsigned short? rearWiper;
        readonly attribute unsigned short? hvacFanDirection;
        readonly attribute unsigned short? hvacFanSpeed;
        readonly attribute short? hvacFanTargetTemp;
        readonly attribute boolean? airConditioning;
        readonly attribute boolean? airRecirculation;
        readonly attribute boolean? heater;
        readonly attribute boolean? defrostWindshield;
        readonly attribute boolean? defrostRearWindow;
        readonly attribute boolean? defrostSideMirrors;
        readonly attribute boolean? steeringWheelHeater;
        readonly attribute boolean? seatHeater;
        readonly attribute boolean? seatCooler;
        readonly attribute unsigned short? windowDriver;
        readonly attribute unsigned short? windowPassenger;
        readonly attribute unsigned short? windowRearLeft;
        readonly attribute unsigned short? windowRearRight;
        readonly attribute unsigned short? sunroofOpenness;
        readonly attribute unsigned short? sunroofTilt;
        readonly attribute boolean? convertibleRoof;
    };
};


