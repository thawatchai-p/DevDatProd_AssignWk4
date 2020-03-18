library(plotly)
library(shiny)
library(shinydashboard)

ui <- dashboardPage(
    dashboardHeader(title = "Wine Class Prediction"),
## Side bar
    dashboardSidebar(
        sidebarMenu(
        menuItem("Model", tabName = "model", icon = icon("box")),
        menuItem("Info", tabName = "info", icon = icon("question")),
        br(),
        tags$p("Version 0.0.1", align = "center")
        )
    ),
## Body content
    dashboardBody(
        tabItems(
        # First tab content
            tabItem(tabName = "model", 
                fluidRow(
                    column(width = 12, h4(icon("box"), HTML("&nbsp;"), tags$b("Model"))),
                    box(title = "Model Prediction", width = 8,
                        fluidRow(column(width = 12, plotlyOutput("modPlotly", width = "100%", height = "100%")),
                                 column(width = 12, tags$h4("Press Predict Button and Wait for the Plot to be generated..."))
                                 ),
                        ),
                    box(tags$h4("Parameters"), width = 4,
                        column(width = 12, sliderInput("predFlav", "Flavanoids", value = 2, min = 0, max = 4, step = 0.25)),
                        column(width = 12, sliderInput("predOd", "OD280/OD315 of diluted wines", value = 2, min = 0, max = 4, step = 0.25)),
                        column(width = 12, sliderInput("predPhe", "Total Phenols", value = 2, min = 0, max = 4, step = 0.25)),
                        column(width = 12, submitButton("Predict!!!", width = "100%"), align = "center"),
                        column(width = 12, tags$h4("Prediction Result: ")),
                        column(width = 12, valueBoxOutput(outputId = "Class", width = 12), align = "center")
                        )
                    
                    
                )
            ),
        # Second tab content
            tabItem(tabName = "info",
                fluidRow(
                    column(width = 12, h4(icon("question"), HTML("&nbsp;"), tags$b("Info"))),
                    box(title = "Dataset Information", width = 6,
                        tags$p("Dataset can be referred as following link:"),  
                        tags$a(href="https://archive.ics.uci.edu/ml/datasets/Wine", "UC Irvine Machine Learning Repository", br()),
                        tags$p("These data are the results of a chemical analysis of wines grown in the same region in Italy but derived from 
                        three different cultivars. The analysis determined the quantities of 13 constituents found in each of the three types of wines.
                        The correlation analysis found that there are 3 parameters that highly correlated with the wine class, and those are:"),
                        tags$ol(tags$li("Flavonoids"),
                                tags$li("OD280/OD315 of diluted wines"),
                                tags$li("Total phenols"))
                        ),
                    HTML('<center><img src="https://praewwedding.com/app/uploads/2015/08/wine-1.jpg" width="520"></center>')
                )
            )
        )
    )
)