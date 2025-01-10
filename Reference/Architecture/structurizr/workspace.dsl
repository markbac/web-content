workspace {

    !adrs adrs
    !docs docs

    model {
        group "Home" {
            CEM = softwareSystem "CEM (VEN)" {
                tags "IoT"
            }
            ESA = softwareSystem "ESA" {
                tags "IoT"
            }
            user = person "User"{
                tags "Person"
            }
        }
        
        Supplier = softwareSystem "Supplier" {
            tags "Supplier"
        }
        
        DNOTSO = softwareSystem "DNO TSO" {
            tags "DNOTSO_SS"
        }
        
        group "DSRSP System" {
            DSRSP = softwareSystem "DSRSP" {
                description "This is a PAS 1878 and 1879 Demand Side Response Service Provider"
                
                tags "DSRSP"
                
                keycloack = container "KeyCloack"
            
                subscriber = container "Subscriber Manager" {
                    tags "DSRSP"
                    sub_load_balancer = component  "Load Balancer"{
                        tags "Google Cloud Platform - Cloud Load Balancing" "GCP"
                    }
                    sub_api_Gateway = component  "API Gateway"{
                        tags "Google Cloud Platform - Apigee API Platform" "GCP"
                    }
                    sub_pub_api = component  "Consumer api"{
                        tags "Google Cloud Platform - Cloud Run" "GCP"
                    }
                    sub_private_api = component  "Consumer & Db api"{
                        tags "Google Cloud Platform - Cloud Run" "GCP"
                    }
                    database = component "Subscriber Database" {
                        tags "Google Cloud Platform - Cloud SQL" "Database" "GCP"
                    }
                }

                edge = container "VTN" {
                    tags "DSRSP"
                    vtn_load_balancer = component  "VTN Load Balancer"{
                        tags "Google Cloud Platform - Cloud Load Balancing" "GCP"
                    }
                    vtn_api_Gateway = component  "VTN API Gateway"{
                        tags "Google Cloud Platform - Apigee API Platform" "GCP"
                    }
                    vtn = component  "VTN"{
                        tags "Google Cloud Platform - Cloud Run" "GCP"
                    }
                }
                
                events = container "Event Manager" {
                    tags "DSRSP"
                    Report_load_balancer = component  "VTN Load Balancer"{
                        tags "Google Cloud Platform - Cloud Load Balancing" "GCP"
                    }
                    Report_api_Gateway = component  "VTN API Gateway"{
                        tags "Google Cloud Platform - Apigee API Platform" "GCP"
                    }
                    Report_API = component  "Report_API"{
                        tags "Google Cloud Platform - Cloud Run" "GCP"
                    }
                    DSR_load_balancer = component  "DSR Load Balancer"{
                        tags "Google Cloud Platform - Cloud Load Balancing" "GCP"
                    }
                    DSR_api_Gateway = component  "DSR API Gateway"{
                        tags "Google Cloud Platform - Apigee API Platform" "GCP"
                    }
                    DSR_Event_Manager = component  "DSR_Event_Manager"{
                        tags "Google Cloud Platform - Cloud Run" "GCP"
                    }
                    DSR_Event_Select_Particpants_API = component  "DSR_Event_Select_Particpants_API"{
                        tags "Google Cloud Platform - Cloud Run" "GCP"
                    }   
                    DSR_Event_Device_manager_API = component  "DSR_Event_Device_manager_API"{
                        tags "Google Cloud Platform - Cloud Run" "GCP"
                    }   
                    Open_LEADR_Interface_API = component  "Open_LEADR_Interface_API"{
                        tags "Google Cloud Platform - Cloud Run" "GCP"
                    }   
                    Device_Interface_API = component  "Device_Interface_API"{
                        tags "Google Cloud Platform - Cloud Run" "GCP"
                    }
                }
            }
        }

        user -> Supplier "User/Supplier Interaction"{
            tags "Human"
        }
        
        ESA -> CEM "Interaface B"
        user -> CEM "User/CEM Interaction"{
            tags "Human"
        }
        
        CEM -> vtn_load_balancer "Interface A (OpenADR)"
        vtn_load_balancer -> vtn_api_Gateway
        vtn_api_Gateway -> vtn
        vtn -> sub_private_api
        vtn -> Open_LEADR_Interface_API
        
        Events -> sub_private_api
        
        DNOTSO -> DSR_load_balancer "DSR Event API (/dsr-event)"
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
        
        DNOTSO -> Report_load_balancer "Report APIs (/reports)"
        DNOTSO -> keycloack "Request Oauth2 client grant"{
            tags "OAUTH"
        }

        Report_load_balancer -> Report_api_Gateway
        Report_api_Gateway -> Report_API
        Report_api_Gateway -> keycloack "Validate Access Token"
        Report_API -> sub_private_api
        
    
        Supplier -> sub_load_balancer "Subscriber API (/extconsumer)"
        Supplier -> keycloack "Request Oauth2 client grant"
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
        systemLandscape DSRSP_Stream_1 "System Overview" { 
            include DSRSP User ESA CEM Supplier DNOTSO
        }
        
        systemLandscape DSRSP_All "Context_All" { 
            include *
            description "This is the System Landscape that the DSRSP sits within"
        }
        

        systemContext DSRSP {
            include *
        }
        
          
        container DSRSP  "DSR" {
            include *
        }

        container DSRSP "include" {
            include * subscriber events edge ESA CEM user Supplier DNOTSO  keycloack DSRSP
        }
        
        component subscriber  "SubscriberComponenets" {
            include *
        }
        
        component edge  "EdgeComponenets" {
            include *
        }
        
        component events  "EventsComponenets" {
            include *
        }
         
        deployment DSRSP "PoC" "PoC" {
            include *
            description "DSRSP PoC"
        }

        component events "allContainers" {
            include sub_private_api sub_pub_api sub_api_Gateway sub_load_balancer Supplier keycloack Report_API Report_api_Gateway Report_load_balancer DNOTSO Open_LEADR_Interface_API Device_Interface_API DSR_Event_Device_manager_API DSR_Event_Select_Particpants_API DSR_Event_Manager DSR_api_Gateway DSR_load_balancer DNOTSO vtn vtn_api_Gateway vtn_load_balancer CEM ESA Supplier user DSRSP database

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
            
            description "Over view of sign up and registration"


        }
        
        dynamic * "Event" "DSR Event" {
            ESA -> CEM "Provide offers"
            CEM -> DSRSP "Provide offers"
            DNOTSO -> DSRSP "Request DSR Event"
            DSRSP -> CEM "Send offer proposal"
            CEM -> ESA  "Send offer proposal"
            description "Over view of DSR Event"


        }
        
        styles {

            element "Element" {
                background #ffffff
            }
            element "Database" {
                shape cylinder
            }
            element "GCP" {                
                background #ffffff
            }
            element "Person" {                
                background #3ED12F
            }
            element "IoT" {
                icon iot.png     
                background #6EAAF0
                shape Ellipse
            }
            element "DSRSP" {
                background darkblue
                border solid 
                strokeWidth  5
                border solid 
                #shape Hexagon
            }

            element "Supplier" {
                shape Circle
                background #AA6EF0
            }
            
            relationship "Human"{
                dashed false
                colour orange
            }

            relationship "OAUTH" {
                properties {
                    security "Client OAuth"
                }
            }

            element "Group" {
                color blue
                border solid 
                strokeWidth  5
                shape RoundedBox
                icon iot.png     
                color darkgreen
            }

        }
        

        theme default
        themes https://static.structurizr.com/themes/google-cloud-platform-v1.5/theme.json
    }

}