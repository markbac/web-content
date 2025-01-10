workspace {

    model {
        user = person "User"
        Supplier = softwareSystem "Supplier" 
        user -> Supplier "User/Supplier Interaction"
        
        group "Home" {
            CEM = softwareSystem "CEM"
            ESA = softwareSystem "ESA"
        }
        
        ESA -> CEM "Interaface B"
        user -> CEM "User/CEM Interaction"
        
        DNOTSO = softwareSystem "DNO TSO"
        group "DSRSP" {
            keycloack = softwareSystem "KeyCloack"
            DSRSP = softwareSystem "DSRSP" {
            
                subscriber = container "Subscriber" {
                    sub_load_balancer = component  "Load Balancer"{
                        tags "Google Cloud Platform - Cloud Load Balancing"
                    }
                    sub_api_Gateway = component  "API Gateway"{
                        tags "Google Cloud Platform - Apigee API Platform"
                    }
                    sub_pub_api = component  "Consumer api"{
                        tags "Google Cloud Platform - Cloud Run"
                    }
                    sub_private_api = component  "Consumer & Db api"{
                        tags "Google Cloud Platform - Cloud Run"
                    }
                    database = component "Subscribner Database" {
                        tags "Google Cloud Platform - Cloud SQL" "Database"
                    }
                }

                edge = container "edge" {
                    vtn_load_balancer = component  "VTN Load Balancer"{
                        tags "Google Cloud Platform - Cloud Load Balancing"
                    }
                    vtn_api_Gateway = component  "VTN API Gateway"{
                        tags "Google Cloud Platform - Apigee API Platform"
                    }
                    vtn = component  "VTN"{
                        tags "Google Cloud Platform - Cloud Run"
                    }
                }
                
                events = container "events" {
                    Report_load_balancer = component  "VTN Load Balancer"{
                        tags "Google Cloud Platform - Cloud Load Balancing"
                    }
                    Report_api_Gateway = component  "VTN API Gateway"{
                        tags "Google Cloud Platform - Apigee API Platform"
                    }
                    Report_API = component  "Report_API"{
                        tags "Google Cloud Platform - Cloud Run"
                    }
                
                    DSR_load_balancer = component  "DSR Load Balancer"{
                        tags "Google Cloud Platform - Cloud Load Balancing"
                    }
                    DSR_api_Gateway = component  "DSR API Gateway"{
                        tags "Google Cloud Platform - Apigee API Platform"
                    }
                    DSR_Event_Manager = component  "DSR_Event_Manager"{
                        tags "Google Cloud Platform - Cloud Run"
                    }
                    DSR_Event_Select_Particpants_API = component  "DSR_Event_Select_Particpants_API"{
                        tags "Google Cloud Platform - Cloud Run"
                    }   
                    DSR_Event_Device_manager_API = component  "DSR_Event_Device_manager_API"{
                        tags "Google Cloud Platform - Cloud Run"
                    }   
                    Open_LEADR_Interface_API = component  "Open_LEADR_Interface_API"{
                        tags "Google Cloud Platform - Cloud Run"
                    }   
                    Device_Interface_API = component  "Device_Interface_API"{
                        tags "Google Cloud Platform - Cloud Run"
                    }  
                        
                }
                
            }
        }
        
        CEM -> vtn_load_balancer "Interface A (OpenADR)"
        vtn_load_balancer -> vtn_api_Gateway
        vtn_api_Gateway -> vtn
        vtn -> sub_private_api
        vtn -> Open_LEADR_Interface_API
        
        Events -> sub_private_api
        
        DNOTSO -> DSR_load_balancer "DSR Event API"
        DSR_load_balancer -> DSR_api_Gateway
        DSR_api_Gateway -> DSR_Event_Manager
        DSR_api_Gateway -> keycloack "Validate Access Token"
        DSR_Event_Manager -> DSR_Event_Device_manager_API
        DSR_Event_Manager -> sub_private_api
        DSR_Event_Manager -> DSR_Event_Select_Particpants_API
        DSR_Event_Select_Particpants_API -> sub_private_api
        DSR_Event_Device_manager_API -> Device_Interface_API
        Device_Interface_API -> DSR_Event_Device_manager_API
        DSR_Event_Device_manager_API -> sub_private_api
        Device_Interface_API -> sub_private_api
        Device_Interface_API -> Open_LEADR_Interface_API
        Open_LEADR_Interface_API -> sub_private_api
        
        
        
        DNOTSO -> Report_load_balancer "Report APIs"
        DNOTSO -> keycloack "Request client grant"
        Report_load_balancer -> Report_api_Gateway
        Report_api_Gateway -> Report_API
        Report_api_Gateway -> keycloack "Validate Access Token"
        Report_API -> sub_private_api
        
    
        Supplier -> sub_load_balancer "Subscribee API"
        Supplier -> keycloack "Request client grant"
        sub_load_balancer -> sub_api_Gateway
        sub_api_Gateway -> keycloack "Validate Access Token"
        sub_api_Gateway -> sub_pub_api "Reads from and writes to"
        sub_pub_api -> sub_private_api "Reads from and writes to"
        sub_private_api -> database "Reads from and writes to"
        
        deploymentEnvironment "PoC" {
            deploymentNode "DSRSP" "" "" {
                deploymentNode "subscriber" "" "" {
                    PoC_subscriber = containerInstance subscriber
                }
            }
        }

    }

    views {
        systemLandscape DSRSP_Stream_1 "Context_All" { 
            include *
            autolayout tb
        }

        systemContext DSRSP {
            include *
            autolayout tb
        }
        
          
        container DSRSP  "DSR" {
            include *
            autolayout tb
        }
        
        component subscriber  "SubscriberComponenets" {
            include *
            autolayout tb
        }
        
        component edge  "EdgeComponenets" {
            include *
            autolayout tb
        }
        
        component events  "EventsComponenets" {
            include *
            autolayout tb
        }
         
        deployment DSRSP "PoC" "PoC" {
            include *
            autoLayout
            description "An example development deployment scenario for the Internet Banking System."
        }
         
        dynamic * "Registration" "Signup and Registration" {
            user -> Supplier "User signs up with supplier for DSRSP"
            Supplier -> DSRSP "Supplier Signs up with DSRSP"
            user -> CEM "User sign into CEM"
            user -> Supplier "provides ESA/CEM info"
            Supplier -> DSRSP "provides ESA/CEM info"
            ESA -> CEM "ESA registers with CEM"
            user -> CEM " requests device reg with DSRSP"
            CEM -> DSRSP "CEM registers with DSRSP"
            
            autolayout tb
            
            description "Over view of sign up and registration"
        }
        
        dynamic * "Event" "DSR Event" {
            ESA -> CEM "Provide offers"
            CEM -> DSRSP "Provide offers"
            DNOTSO -> DSRSP "Request DSR Event"
            DSRSP -> CEM "Send offer proposal"
            CEM -> ESA  "Send offer proposal"
            
            autolayout tb
            
            description "Over view of DSR Event"
        }
        
        
        dynamic * {
            user -> Supplier "User signs up with supplier for DSRSP"
            Supplier -> DSRSP "Supplier Signs up with DSRSP"
            user -> CEM "User sign into CEM"
            user -> Supplier "provides ESA/CEM info"
            Supplier -> DSRSP "provides ESA/CEM info"
            ESA -> CEM "ESA registers with CEM"
            user -> CEM " requests device reg with DSRSP"
            CEM -> DSRSP "CEM registers with DSRSP"
            
            autolayout tb
            
             description "Over view of sign up and registration"
        }
        
        styles 
            element database {
                shape cylinder
                background #ffffff
            }
        }

        theme default
        themes https://static.structurizr.com/themes/google-cloud-platform-v1.5/theme.json
    }

}