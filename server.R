
#if (!require("shiny")){
#    install.packages("shiny")
#}
library(shiny)

#if (!require("sqldf")){
#    install.packages("sqldf")
#}
library(sqldf)

library(shiny)

source("scripts/create_map.R")
source("scripts/read_data.R")
source("scripts/save_data.R")

shinyServer(function(input, output, session) {

    
    data <- readData()
    wkurl = "https://www.wikiloc.com"
    #insertIFN_VA_Class(data)
    activeParcela <- reactiveValues(count=1, data=data, wkurl=wkurl)
    
    tableData <- reactiveVal()
    
    output$map <- renderLeaflet(
        create_map(activeParcela$data[activeParcela$count, "coords_latitude"],activeParcela$data[activeParcela$count, "coords_longitude"])
        )
    
    observeEvent(input$tabs, {
        if(input$tabs == "data"){
            print("data tab selected")
            tableData(readIFN_WL_TrailN())
        }
    })
    
    output$dataTable = renderTable({
        tableData()[!is.na(tableData()$sys_dt_done),]
    })
    
    output$link = renderUI({
        lat <- activeParcela$data[activeParcela$count,"coords_latitude"]
        long <- activeParcela$data[activeParcela$count,"coords_longitude"]
        latn <- lat + 0.019063
        lats <- lat - 0.019063
        longe <- long + 0.036554
        longw <- long - 0.036554
        
        url <- paste("https://www.wikiloc.com/wikiloc/map.do?sw=",lats,"%2C",longw,"&ne=",latn,"%2C",longe,"&zdp=(",long,"%2C",lat,"%2C88)&page=1")
        link <- a("View Wikiloc page", href=url, target="_blank")
        HTML(paste(link))
    })
    
    #output$frame <- renderUI({
    #    #"<iframe frameBorder="0" scrolling="no" src="https://www.wikiloc.com/wikiloc/spatialArtifacts.do?event=view&id=89326866&measures=off&title=off&near=off&images=off&maptype=H" width="500" height="400"></iframe><div style="color:#777;font-size:11px;line-height:16px;">Powered by <a style="color:#06d;font-size:11px;line-height:16px;" target="_blank" href="https://www.wikiloc.com">Wikiloc</a></div>"
    #    
    #    url = "https://www.wikiloc.com/wikiloc/map.do?sw=42.24712830147751%2C2.202372550964356&ne=42.2534895551433%2C2.214732170104981&zdp=(2.2085523605346684%2C42.250309008501105%2C88)&page=1"
    #    test <- tags$iframe(src=url, height=600, width=1070)
    #    print(test)
    #    test
    #})
  
    output$title <- renderText({
        return(paste(activeParcela$data[activeParcela$count,]$plot_id, 
            " - ",
            paste(activeParcela$data[activeParcela$count,]$admin_municipality,
            activeParcela$data[activeParcela$count,]$admin_region,
            activeParcela$data[activeParcela$count,]$admin_province,
            activeParcela$data[activeParcela$count,]$admin_aut_community, sep=", "),  

            paste(" (",round(activeParcela$data[activeParcela$count,]$topo_altitude_asl, digits=0), " m)", sep=""), 
            sep=""))
        })
    
   observeEvent(input$nextButton, {
            
        if (is.na(input$trailNumber))
        {
            showNotification("Debe especificar el número de rutas detectadas en Wikiloc")
        } else{
            activeParcela$data[activeParcela$count,]$trailNumber <- input$trailNumber
            
            #activeParcela$wkurl <- "https://www.wikiloc.com/wikiloc/map.do?sw=42.24712830147751%2C2.202372550964356&ne=42.2534895551433%2C2.214732170104981&zdp=(2.2085523605346684%2C42.250309008501105%2C88)&page=1"
            
            activeParcela$data[activeParcela$count,]$sys_dt_done <- Sys.time()
            
            updateIFN_WL_TrailN(activeParcela$data[activeParcela$count,])
            
            if(activeParcela$count>=nrow(activeParcela$data)){
                activeParcela$data <- activeParcela$data[1,]
                data <- readData()
                activeParcela$data <- rbind(activeParcela$data, data)
                activeParcela$count = 2
            } else{
                activeParcela$count = activeParcela$count + 1
            }
           
            updateSliderInput(session, "trailNumber", value=NA)
          
            enable("previousButton")
        }
        
    })
    observeEvent(input$previousButton, {

        activeParcela$count = activeParcela$count - 1
        
        updateSliderInput(session, "trailNumber", value=activeParcela$data[activeParcela$count,]$trailNumber)
       
        disable("previousButton")
    })
    
})
