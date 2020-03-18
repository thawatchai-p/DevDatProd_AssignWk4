library(caret)
library(corrplot)
library(plotly)
library(tidyverse)

raw.data <- read.csv("./wine.csv", header = FALSE)
colnames(raw.data) <- c("Class", "Alcohol", "Malic acid", "Ash", "Alkalinity_of_ash",
                    "Magnesium", "Total_phenols", "Flavanoids",
                    "Nonflavanoid phenols", "Proanthocyanins",
                    "Color intensity", "Hue", "OD280.OD315",
                    "Proline")
summary(raw.data); str(raw.data)

cor.data <- cor(raw.data); cor.data
corrplot(cor.data, method = "color", type = "lower", addCoef.col = "black")

cor.val <- data.frame(cor.coeff = cor(raw.data)[1,]) %>% rownames_to_column(); cor.val

sign.col <- which(abs(cor.val$cor.coeff) > 0.67 & abs(cor.val$cor.coeff < 0.90))

data <- bind_cols(as.data.frame(raw.data$Class), raw.data[ ,sign.col])
colnames(data) <- c("Class", "Total_phenols", "Flavanoids", "OD280.OD315")

data$Class[data$Class == 1] <- "A"
data$Class[data$Class == 2] <- "B"
data$Class[data$Class == 3] <- "C"
data$Class <- as.factor(data$Class)

## Train the model
modFit <- train(Class~., method = "rf", data = data)

## Predict the new data
newdata <- data.frame(4, 3.5, 2)
colnames(newdata) <- c("Total_phenols", "Flavanoids", "OD280.OD315")
modPred <- predict(modFit, newdata = newdata)
modPred

## Prepare the data for plotly
plot.new <- cbind("Class" = paste0("New: ", modPred), newdata)
plot.data <- rbind(data, plot.new)

## Plotly
colors <- c('#008744', '#0057e7', '#d62d20', '#ffa700')
mod.plotly <- plot_ly(x = plot.data$Flavanoids, y = plot.data$OD280.OD315, z = plot.data$Total_phenols,
                  type = "scatter3d", color = factor(plot.data$Class), alpha = 0.8, mode = "markers",
                  colors = colors)
mod.plotly <- mod.plotly %>% layout(scene = list(xaxis = list(title = "Flavanoids"),
                                         yaxis = list(title = "OD280/OD315"),
                                         zaxis = list(title = "Total phenols")
                                         )
                            )
mod.plotly
##