#
# Кусочек кода для проверки подключения модели.
#


####

library(shiny)
library(shinycssloaders)
library(dplyr)
library(formattable)

library(reticulate)
# пакетик из питона
gensim = import("gensim")
# модель
model = gensim$models$Word2Vec$load('~/MUSIC_REC_SYSTEM/w2v_10m.model')

####

# Define UI 
ui = fluidPage(
   
   # Название приложения
   titlePanel("test app"),
   
   # Sidebar 
   # задает расположение элементов (сайдбар и основная часть)
   sidebarLayout(
     sidebarPanel(  # боковая панель; управляющие элементы 
   
       # Copy the line below to make a text input box
       textInput("artists", label = h3("write smth here"), value = "adele")
      ),
      
      # колоночка справа с текстиком кароч
      mainPanel(
        fluidRow(column(7, verbatimTextOutput("value"))),
        # прикольно показывается спиннер пока табличка и вот это вот всё строится (type = 6 - nice one)
        # но если загрузка занимает менее секунды, но НЕ нужно использовать. потом уберем
        tabPanel("Table", tableOutput("table")  %>% withSpinner())
      )
   )
)

# Define server logic 
server = function(input, output) {
  
  # You can access the value of the widget with input$text, e.g.
  output$value = renderPrint({ input$artists })

  
  modelOutput = reactive({
    df = matrix(unlist(model$wv$most_similar(input$artists)), ncol=2, byrow=T)
  })
  
  output$table = renderTable({
    df_output = as.data.frame(x=modelOutput())
    colnames(df_output) = c('топ предикт', 'а точно ли топ')
    df_output}
    , width = '75%')
}


# вжух
shinyApp(ui = ui, server = server)

