library(shiny)
library(ggplot2)



fluidPage(
  
  
  
  # Sidebar 
      sidebarPanel(
        headerPanel("Chicago Cubs Key Statistics"),
        
        # Specification of range within an interval
        sliderInput("range", "Select years:",
                    min = 1871, max = 2015, value = c(1998,2014),sep = ""),
        
        # Check boxes for the source sectors
        checkboxGroupInput("source_choose", label = "Select Statistic",
                           choices = c("Home Runs",
                                       "Earned Run Average"), 
                           selected = c("Home Runs",
                                         "Earned Run Average"),
      
      mainPanel(
        tags$head(tags$style("#plot{height:100vh !important;}")),
        plotOutput('plot')
      )
    )
  )
)