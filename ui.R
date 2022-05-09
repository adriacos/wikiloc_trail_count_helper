
#if (!require("shiny")){
#    install.packages("shiny")
#}
library(shiny)

#if (!require("shinyjs")){
#    install.packages("shinyjs")
#}
library(shinyjs)

#if (!require("leaflet")){
#    install.packages("leaflet")
#}
library(leaflet)

shinyUI(fluidPage(
    
    
    tabsetPanel(type = "tabs", id = "tabs",
                tabPanel("classificador", 
                         headerPanel(
                             textOutput("title")
                         ),
                         sidebarLayout(
                             mainPanel(
                                 leafletOutput("map", height=624),
                                 
                                 #htmlOutput("frame")
                             ),
                             sidebarPanel(
                                wellPanel(
                                    numericInput("trailNumber", "Number of trails", value=NULL),   
                                ),
                                wellPanel(
                                    uiOutput("link"),
                                ), 
                                wellPanel(
                                    useShinyjs(),
                                    fluidRow(
                                        column(6, 
                                               disabled(actionButton(inputId="previousButton", label="Previous"))
                                        ),
                                        column(6,
                                               actionButton(inputId="nextButton", label="Next")
                                        )
                                    ))
                             )
                         )  
                ),
                tabPanel("data", 
                         tableOutput('dataTable')
                    ))
   
))






