library(e1071)
library(caret)
library(plotly)
library(randomForest)
library(shiny)
library(shinydashboard)
library(tidyverse)

# Define server logic
shinyServer(function(input, output) {
    
    # Read the data file
    raw.data <- read.csv("wine.csv", header = FALSE)
    colnames(raw.data) <- c("Class", "Alcohol", "Malic acid", "Ash", "Alkalinity of ash",
                        "Magnesium", "Total phenols", "Flavanoids",
                        "Nonflavanoid phenols", "Proanthocyanins",
                        "Color intensity", "Hue", "OD280.OD315",
                        "Proline")
    
    # Correlation analysis
    cor.val <- data.frame(cor.coeff = cor(raw.data)[1,]) %>% rownames_to_column()
    sign.col <- which(abs(cor.val$cor.coeff) > 0.67 & abs(cor.val$cor.coeff < 0.90))
    
    # Select the most 3 correlation parameters
    data <- bind_cols(as.data.frame(raw.data$Class), raw.data[ ,sign.col])
    colnames(data) <- c("Class", "Total_phenols", "Flavanoids", "OD280.OD315")
    
    # Convert numeric class to factor (A, B, and C)
    data$Class[data$Class == 1] <- "A"
    data$Class[data$Class == 2] <- "B"
    data$Class[data$Class == 3] <- "C"
    data$Class <- as.factor(data$Class)
    
    # Train the model
    modFit <- train(Class~., method = "rf", data = data)
    
    # Predict the new data
    modPred <- reactive({
        TotPInput <- input$predPhe
        FlavInput <- input$predFlav
        ODInput <- input$predOd
        predict(modFit, newdata = data.frame(Total_phenols = TotPInput, Flavanoids = FlavInput, OD280.OD315 = ODInput))
    })
    
    # Plot the data
    output$modPlotly <- renderPlotly({

        # Prepare data for plotly
        TotPInput <- input$predPhe
        FlavInput <- input$predFlav
        ODInput <- input$predOd
        plotNew <- data.frame(Class = "New", Total_phenols = TotPInput, Flavanoids = FlavInput, OD280.OD315 = ODInput)
        plotData <- rbind(data, plotNew)
        
        # Draw the plotly
        colors <- c('#008744', '#0057e7', '#d62d20', '#ffa700')
        modPlotly <- plot_ly(x = plotData$Flavanoids, y = plotData$OD280.OD315, z = plotData$Total_phenols,
                             type = "scatter3d", color = plotData$Class, alpha = 0.8, mode = "markers", colors = colors)
        modPlotly <- modPlotly %>% layout(scene = list(xaxis = list(title = "Flavanoids"),
                                                         yaxis = list(title = "OD280/OD315"),
                                                         zaxis = list(title = "Total phenols")
        )
        )
        
    })
    
    output$flav <- renderText({
        input$predFlav
        })
    
    output$od <- renderText({
        input$predOd
        })
    
    output$phe <- renderText({
        input$predPhe
        })
    
    output$Class <- renderValueBox({
        Class <- modPred()
        valueBox(Class, "CLASS", color = 'yellow')
    })

})