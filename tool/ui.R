#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#
options(java.parameters = "-Xmx1500m")
library(shiny)
library(shinyjs)
library(shinythemes)
library(shinydashboard)
library(shinyBS)

library(xlsx) # Write to excel
library(readxl) # Read from excel
library(tm) # Text Mining
library(pdftools) # Text Extraction
library(SnowballC) # Stemming
library(wordcloud) # Word Cloud
library(stringr) # Count substring in string
library(textcat) # Detect language of text
library(rhandsontable) # Interactive tables
library(plotly) # Interactive plots

options(shiny.maxRequestSize = 768 * 1366 ^ 5)

dashboardPage(title="Openmasses",
  
  #Header of dashboard
  dashboardHeader(
    titleWidth = 200,
    title = div(img(src="uu.png", height = 40)),
    dropdownMenuOutput("messageMenu")
  ),
  
  #Dashboard menu
  dashboardSidebar(
    width = 350,
    br(),
    h3("Input", align = "center"),
    textInput('title', 'Title',placeholder = "Give a title for the analysis..."),
    fileInput('pdfs', 'Upload document(s) as PDF or Zip', multiple = 'TRUE', accept = c('application/x-rar-compressed, application/octet-stream', 'application/zip, application/octet-stream', 'application/pdf')),
    fileInput('media', 'Upload media data', multiple = 'TRUE'), #Use as accept a pickle dump, use reticulate to properly open it
    fileInput('longlists', 'Upload longlist(s) as Excel', multiple = 'TRUE', accept = c('application/vnd.ms-excel', 'application/x-excel', 'application/x-msexcel', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')),
    radioButtons("scoring", "Scoring scheme",
                 c("Count" = "1",
                   "Frequency" = "2",
                   "Relative" = "3",
                   "Weighted" = "4"), selected = 2, inline = T),
    radioButtons("longlistoption", "Longlist Option",
                 c("Automated keywords" = "1",
                   "Predefined keywords" = "2"),
                   selected = 2, inline = T),
    radioButtons("dimensionReduction", "Weigh the matrix axes?",
                 c("Automated" = "1",
                   "Manual" = "2"),
                 selected = 1, inline = T),
    conditionalPanel(
      id = "threshold",
      condition = "input.scoring == 3",
      numericInput("threshold", "Threshold:", min = 0, max = 10, value = 0.05, step = 0.01)
    ),
    tableOutput("table.pdfs"),
    tableOutput('table.media'), 
    tableOutput("table.longlists")
  ),
  
  #Body of dashboard
  dashboardBody(
    useShinyjs(),
    tags$head(tags$link(rel = "shortcut icon", href = "favicon.ico")),
    
    #Creates style of entire dashboard
    tags$head(tags$style(HTML('
      .skin-blue .main-header .logo {
        background-color: white;
      }
      .skin-blue .main-header .logo:hover {
        background-color: white;
      }
      .skin-blue .main-header .navbar {
        background-color: white;
      }
      .skin-blue .wrapper .main-sidebar.shiny-bound-input{
        background-color: #222d32;
      }
      .skin-blue .wrapper {
        background-color: white;
      }
      .skin-blue .main-header .navbar .sidebar-toggle {
        color: #222d32;s
        border-right: 1px solid #eee;
        border-left: 1px solid #eee;
        margin-left: -1px;
      }
      .skin-blue .main-header .navbar .sidebar-toggle:hover {
        color: white;
        background-color: #222d32;
      }
      .main-sidebar .sidebar .table tbody tr {
        font-style: italic;
      }
      .main-sidebar .sidebar .table tbody tr:hover {
        background-color: #384246;
      }
      .main-sidebar .shiny-input-container {
        width: 100%;
      }
      .btn.btn-default.blue.action-button.shiny-bound-input {
        margin: auto;
        background-color: #3c8dbc;
        border-color: #367fa9;
        border-radius: 3px;
        -webkit-box-shadow: none;
        box-shadow: none;
        border: 1px solid transparent;
        color: #fff;
      }
      .btn.btn-default.action-button.blue.shiny-bound-input:hover{
        background-color: #367ea9;
      }
      .btn.btn-default.action-button.blue.shiny-bound-input:active{
        background-color: #245470;
      }
      .btn.btn-default.action-button.shinyjs-disabled.shiny-bound-input.disabled, .btn.btn-default.shiny-download-link.btn-success.shinyjs-disabled.shiny-bound-output.disabled {
        background-color: #832a2a;
        border: 1px solid transparent;
      }
      .btn.btn-default.shiny-download-link.btn-success.shinyjs-disabled.shiny-bound-output.disabled {
        pointer-events: none;
      }
      .btn-success {
        color: white;
      }
      .btn {
        white-space: normal;
      }
      a.btn.disabled{
        pointer-events: visible;
      }
      .content {
        padding: 0px;
      }
      .content-wrapper {
        padding-bottom: 1px;
        background-color: #f7f7f7;
      }
      .nav-tabs-custom, .nav-tabs-custom>.tab-content, .nav-tabs-custom>.nav-tabs>li.active>a:hover, .nav-tabs-custom>.nav-tabs>li.active:hover {
        background-color: #f7f7f7;
        box-shadow: none;
      }
      .nav-tabs-custom>.nav-tabs {
        border-color: #222D32;
        background-color: #c9cccd;
      }
      .nav-tabs-custom>.nav-tabs>li.active>a {
        border-left-color: #222D32;
        border-right-color: #222D32;
        background-color: #f7f7f7;
        pointer-events:none;
      }
      .nav-tabs-custom>.nav-tabs>li.active>a, .nav-tabs-custom>.nav-tabs>li>a {
        color: #222d32;
      }
      .nav-tabs-custom>.nav-tabs>li>a:hover {
        color: #307096;
      }
      h1 {
        color: #3c8dbc;
      }
      .control-label {
        font-weight: normal;
      }
      .missing {
        color: #832a2a;
        opacity: .65;
      }
      .box-primary {
        background-color: white;
        box-shadow: 1px 4px 6px 0 rgba(0,0,0,.15);
      }
      .box-warning {
        background-color: white;
      }
      .table-striped>tbody>tr:hover {
        background-color: #222d32;
        color: white;
      }
      .well {
        font-size: 30px;
        margin-top: 30px;
        margin-bottom: 50px;
      }
      .shiny-plot-output {
        margin-bottom: 20px;
      }
      .col-sm-12 .box.box-primary {
          padding-left: 15px;
          padding-right: 15px;
      }
      .tab-pane:nth-child(2), .tab-pane:nth-child(3)  {
          padding-left: 15px;
          padding-right: 15px;
      }
      .box-body > .col-sm-12 {
        padding: 0px;
      }
      .tab-pane:nth-child(2) .box-body, .tab-pane:nth-child(3) .box-body {
        padding-left: 25px;
        padding-right: 25px;
      }
      .nav-tabs-custom > .tab-content {
        padding-top: 5px;
      }
      .handsontable {
          white-space: normal!important;
      }
      #tdm {
        padding: 0;
      }
      .nav-tabs-custom>.nav-tabs>li.active {
        pointer-events:none;
      }
      .not-allowed {
        cursor: not-allowed;
      }
      .control-label {
        font-weight: bold;
      }
      #threshold div {
        padding-top: 0px;
        margin-top: -5px;
        padding-bottom: 10px;
      }
      .skin-blue, .skin-blue .wrapper {
        background-color: #f7f7f7;
      }
      #dummy img {
        width: 100%;
      }
      @media (min-width: 767px){
        .tab-pane:nth-child(1) .row .col-sm-6:nth-child(2) {
          padding-right: 0px;
        }
        .tab-pane:nth-child(1) .row .col-sm-6:nth-child(3) {
          padding-left: 0px;
        }
      }
      @media (max-width: 767px){
        .main-header .navbar.navbar-static-top {
          margin-top: -50PX;
          background-color: transparent;
        }
      }
  '))),
  
  #Creates a tabbox with many panels, for every type of analysis
  tabBox(
    id = "tabset", width = "100%",
    tabPanel("Peer analysis", 
      fluidRow(
        br(),
        column(
          width = 6, align = "center",
          box(width = 12, 
            title = "PDF Word Cloud", status = "primary",
            align = "center",
            h1(span(shiny::icon("file-pdf-o"), id = "pdf1", class = "missing")),
            disabled(
              actionButton("wordCloudButtonPDF", "Create PDF Word Cloud", icon("basdfasdf"), status = "primary", class="blue")
            ),
            br(),
            br(),
            div(span(shiny::icon("cloud"), id="iconWordCloudPDFEmpty"), hidden(span(shiny::icon("circle-o-notch", class = "fa-spin fa-fw"), id="iconWordCloudPDFLoad")), class = "well well-sm", id = "placeholderWordCloudPDF"),
            hidden(
              plotOutput(outputId = "wordCloudPlotPDF")
            ),
            box(width = 12,
              title = "Settings", status = "warning", collapsible = TRUE, collapsed=TRUE,
                sliderInput(inputId = "wordCloudPeersNumber",
                            label = "Number of words in cloud:",
                            min = 80, max = 150, value = 150, step = 1)
            )
          )
        ),
        column(width = 6, align = "center",
          box(width = 12,
            title = "Longlist Word Cloud", status = "primary",
            align = "center",
            h1(span(shiny::icon("file-pdf-o"), id="pdf2", class = "missing"), " + ", span(shiny::icon("file-excel-o"), id="excel1", class = "missing")),
            disabled(
              actionButton("wordCloudButtonLonglist", "Create Longlist Word Cloud", icon("cloud"), status = "primary", class="blue")
            ),
            br(),
            br(),
            div(span(shiny::icon("cloud"), id = "iconWordCloudLonglistEmpty"), hidden(span(shiny::icon("circle-o-notch", class = "fa-spin fa-fw"), id="iconWordCloudLonglistLoad")), class = "well well-sm", id = "placeholderWordCloudLonglist"),
            hidden(
              plotOutput(outputId = "wordCloudPlotLonglist")
            ),
            box(width = 12,
                title = "Settings", status = "warning", collapsible = TRUE, collapsed = TRUE,
                sliderInput(inputId = "wordCloudLonglistNumber",
                            label = "Number of words in cloud:",
                            min = 30, max = 80, value = 55, step = 1)
            )
          )
        )
      ),
      fluidRow(
        br(),
        align = "center",
        box(width = 12,
            title = "Term Document Table", status = "primary",
            align = "center",
            fluidRow(
              column(width = 6,
                     align = "center",
                     h1(span(shiny::icon("file-pdf-o"), id = "pdf3", class = "missing"), " + ", span(shiny::icon("file-excel-o"), id = "excel2", class = "missing")),
                     disabled(
                       actionButton("tdmButton", "Create Term Document Table", icon("table"), status = "primary", class="blue")
                     )
              ),
              column(width = 6,
                     align = "center",
                     h1(span(shiny::icon("file-pdf-o"), id = "pdf4", class = "missing"), " + ", span(shiny::icon("file-excel-o"), id = "excel3", class = "missing")),
                     div(class="not-allowed", id="not-allowed",
                         disabled(
                           downloadButton("tdmDownload", "Download Term Document Table", class = "btn-success")
                         )
                     ),
                     br(),
                     hidden(
                       downloadButton("logDownload", "Download log", class = "btn-success") # , icon="cloud")
                     )
              )
            ),
            fluidRow(
              br(),
              div(span(shiny::icon("table"), id = "iconTDMEmpty"), hidden(span(shiny::icon("circle-o-notch", class = "fa-spin fa-fw"), id="iconTDMLoad")), class = "well well-sm ", id = "placeholderTDM"),
              hidden(
                column(width = 12, id = "tdm",
                       title = "Term Document Table", status = "primary",
                       dataTableOutput(outputId = "tdm")
                )
              )
            )
        )
      )
    ),
    tabPanel('News analysis',
      fluidRow(
        br(),
        column(width = 6, align = "center",
               box(width = 12, 
                   title = "News Word Cloud", status = "primary",
                   align = "center",
                   h1(span(shiny::icon("rss"), id = "media1", class = "missing")),
                   disabled(
                     actionButton("wordCloudButtonNews", "Create News Word Cloud", icon("basdfasdf"), status = "primary", class="blue")
                   ),
                   br(),
                   br(),
                   div(span(shiny::icon("cloud"), id="iconWordCloudNewsEmpty"), hidden(span(shiny::icon("circle-o-notch", class = "fa-spin fa-fw"), id="iconWordCloudNewsLoad")), class = "well well-sm", id = "placeholderWordCloudNews"),
                   hidden(
                     plotOutput(outputId = "wordCloudPlotNews")
                   ),
                   box(width = 12,
                       title = "Settings", status = "warning", collapsible = TRUE, collapsed=TRUE,
                       sliderInput(inputId = "wordCloudNewsNumber",
                                   label = "Number of words in cloud:",
                                   min = 80, max = 150, value = 150, step = 1)
                   )
               )
        )
      )
    ),
    tabPanel('Media analysis',
      fluidRow(
        br(),
        column(width = 6, align = "center",
          box(width = 12, 
            title = "Reddit Word Cloud", status = "primary",
            align = "center",
            h1(span(shiny::icon("reddit"), id = "media5", class = "missing")),
            disabled(
              actionButton("wordCloudButtonReddit", "Create Reddit Word Cloud", icon("basdfasdf"), status = "primary", class="blue")
            ),
            br(),
            br(),
            div(span(shiny::icon("cloud"), id="iconWordCloudRedditEmpty"), hidden(span(shiny::icon("circle-o-notch", class = "fa-spin fa-fw"), id="iconWordCloudRedditLoad")), class = "well well-sm", id = "placeholderWordCloudReddit"),
            hidden(
              plotOutput(outputId = "wordCloudPlotReddit")
            ),
            box(width = 12,
               title = "Settings", status = "warning", collapsible = TRUE, collapsed=TRUE,
               sliderInput(inputId = "wordCloudRedditNumber",
                           label = "Number of words in cloud:",
                           min = 80, max = 150, value = 150, step = 1)
            )
          )
        ),
        column(width = 6, align = "center",
          box(width = 12, 
            title = "Twitter Media Word Cloud", status = "primary",
            align = "center",
            h1(span(shiny::icon("twitter-square"), id = "media2", class = "missing")),
            disabled(
              actionButton("wordCloudButtonTwitter", "Create Twitter Word Cloud", icon("basdfasdf"), status = "primary", class="blue")
            ),
            br(),
            br(),
            div(span(shiny::icon("cloud"), id="iconWordCloudTwitterEmpty"), hidden(span(shiny::icon("circle-o-notch", class = "fa-spin fa-fw"), id="iconWordCloudTwitterLoad")), class = "well well-sm", id = "placeholderWordCloudTwitter"),
            hidden(
              plotOutput(outputId = "wordCloudPlotTwitter")
            ),
            box(width = 12,
               title = "Settings", status = "warning", collapsible = TRUE, collapsed=TRUE,
               sliderInput(inputId = "wordCloudTwitterNumber",
                           label = "Number of words in cloud:",
                           min = 80, max = 150, value = 150, step = 1)
            )
          )
        )
      ),
      fluidRow(
        br(),
        align = "center",
        box(width = 12,
            title = "Term Document Media Table", status = "primary",
            align = "center",
            fluidRow(
              column(width = 6,
                     align = "center",
                     h1(span(shiny::icon("file"), id = "media3", class = "missing"), " + ", span(shiny::icon("file-excel-o"), id = "excel5", class = "missing")),
                     disabled(
                       actionButton("tdmMediaButton", "Create Term Document Media Table", icon("table"), status = "primary", class="blue")
                     )
              ),
              'Download function to be implemented later'
              # column(width = 6,
              #         align = "center",
              #         h1(span(shiny::icon("file-pdf-o"), id = "media4", class = "missing"), " + ", span(shiny::icon("file-excel-o"), id = "excel6", class = "missing")),
              #         div(class="not-allowed", id="not-allowed",
              #             disabled(
              #               downloadButton("tdmMediaDownload", "Download Term Document Media Table", class = "btn-success")
              #            )
              #         ),
              #         br(),
              #         hidden(
              #           downloadButton("logDownloadMedia", "Download log Media", class = "btn-success", icon="cloud")
              #         )
              # )
            ),
            fluidRow(
              br(),
              div(span(shiny::icon("table"), id = "iconTDMMediaEmpty"), hidden(span(shiny::icon("circle-o-notch", class = "fa-spin fa-fw"), id="iconTDMMediaLoad")), class = "well well-sm ", id = "placeholderTDMMedia"),
              hidden(
                column(width = 12, id = "tdmMedia",
                       title = "Term Document Media Table", status = "primary",
                       dataTableOutput(outputId = "tdmMedia")
                )
              )
            )
        )
      )
    ),
    
    tabPanel("Matrix",
             fluidRow(
               br(),
               align = "center",
               box(width = 12,
                   title = "Matrix", status = "primary",
                   align = "center",
                   fluidRow(
                     h1(span(shiny::icon("file-pdf-o"), id = "pdf5", class = "missing"), " + ", span(shiny::icon("file-excel-o"), id = "excel4", class = "missing"),
                        " + ", span(shiny::icon("rss"), id = "media6", class = "missing")),
                     disabled(
                       actionButton("plotButtonMatrix", "Create Matrix", icon("line-chart"), status = "primary", class="blue")
                     ),
                     br(),
                     br(),
                     div(span(shiny::icon("line-chart"), id = "iconPlotEmpty"), hidden(span(shiny::icon("circle-o-notch", class = "fa-spin fa-fw"), id="iconPlotLoad")), class = "well well-sm", id = "placeholderPlot"),
                     plotlyOutput(outputId = "plot", height = "700px", width = "700px"),
                     br(),
                     br()
                   ),
                   fluidRow(
                     hidden(
                       div(
                         id = "scoreBox",
                         box(width = 12,
                             title = "Adjust scores", status = "warning", collapsible = TRUE, collapsed = FALSE,
                             align = "left",
                             checkboxGroupInput('X_dimension','Select sources for X-axis',
                                                c('Peer Reports' = '1', 'Internal' = '2', 'News' = '3', 'Twitter' = '4', 'Reddit' = '5'),
                                                inline = TRUE, selected = c(1)),
                             br(),
                             checkboxGroupInput('Y_dimension','Select sources for Y-axis',
                                                c('Peer Reports' = '1', 'Internal' = '2', 'News' = '3', 'Twitter' = '4', 'Reddit' = '5'),
                                                inline = TRUE, selected = c(3)),
                             conditionalPanel(
                               id = 'weightconditioner',
                               condition = 'input.dimensionReduction == 2',
                               numericInput('weightPeers','Peer report weight', value = 1, step = 0.1),
                               numericInput('weightInternal','Internal weight', value = 1, step = 0.1),
                               numericInput('weightNews','News weight', value = 1, step = 0.1),
                               numericInput('weightTwitter','Twitter weight', value = 1, step = 0.1),
                               numericInput('weightReddit','Reddit weight', value = 1, step = 0.1)
                             ),
                             rHandsontableOutput("table.plot", height="auto")
                         )
                       )
                     )
                   )
               )
             )
    ),
    
    tabPanel("Media collector",
             p("Type in all the search terms"),
             textInput('searchTermsInput', 'Search terms', width = '600px'),
             actionButton('collectButton', 'Collect data'),
             actionButton('analyzeButton', 'Analyze'),
             rHandsontableOutput('searchTerms', height = 'auto'),
             tableOutput("searchTermsTable")
             
    ),
      
    tabPanel("Manual",
      p("an example longlist can be downloaded here"),
      downloadButton("exampleLongListDownload", "Download Example Longlist", class = "btn-success")) #, icon = "cloud"))
    ),
  
  # Set tooltips
  bsTooltip(id = "pdf1", title = "PDF file(s) required", placement = "top", trigger = "hover"),
  bsTooltip(id = "pdf2", title = "PDF file(s) required", placement = "top", trigger = "hover"),
  bsTooltip(id = "pdf3", title = "PDF file(s) required", placement = "top", trigger = "hover"),
  bsTooltip(id = "pdf4", title = "PDF file(s) required", placement = "top", trigger = "hover"),
  bsTooltip(id = "pdf5", title = "PDF file(s) required", placement = "top", trigger = "hover"),
  bsTooltip(id = 'media1', title = 'Upload media analysis', placement = 'top', trigger = 'hover'),
  bsTooltip(id = 'media2', title = 'Upload media analysis', placement = 'top', trigger = 'hover'),
  bsTooltip(id = 'media3', title = 'Upload media analysis', placement = 'top', trigger = 'hover'),
  bsTooltip(id = 'media4', title = 'Upload media analysis', placement = 'top', trigger = 'hover'),
  bsTooltip(id = 'media5', title = 'Upload media analysis', placement = 'top', trigger = 'hover'),
  bsTooltip(id = 'media6', title = 'Upload media analysis', placement = 'top', trigger = 'hover'),
  bsTooltip(id = "excel1", title = "Longlist file(s) required", placement = "top", trigger = "hover"),
  bsTooltip(id = "excel2", title = "Longlist file(s) required", placement = "top", trigger = "hover"),
  bsTooltip(id = "excel3", title = "Longlist file(s) required", placement = "top", trigger = "hover"),
  bsTooltip(id = "excel4", title = "Longlist file(s) required", placement = "top", trigger = "hover"),
  bsTooltip(id = "excel5", title = "Longlist file(s) required", placement = "top", trigger = "hover"),
  bsTooltip(id = "excel6", title = "Longlist file(s) required", placement = "top", trigger = "hover")
  )
)
