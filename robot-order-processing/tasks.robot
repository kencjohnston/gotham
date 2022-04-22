*** Settings ***
Library           RPA.Browser.Selenium    auto_close=${FALSE}
Library           RPA.HTTP
Library           RPA.Tables
Library           RPA.Archive
Library           RPA.PDF
Documentation     Order robots from RobotSpareBin Industries inc.
...               Saves the order HTML as a PDF for later review.
...               Saves a screenshot to confirm the order.
...               Adds the screenshot of the robot to the PDF Receipt. 
...               Creates a ZIP archive of the receipts and the images.

*** Tasks ***
Order robots from RobotSpareBin Industries Inc
    Open the robot order website
    ${orders}=   Get orders
    FOR    ${row}    IN    @{orders}
        Close the annoying modal
        Fill the form    ${row}
        Preview the robot
        ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
        Wait Until Keyword Succeeds    10x    0.5s    Submit the order
        ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
        Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    Close the annoying modal
    Create a ZIP file of the receipts

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Log    Website Opened.

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${orders}=    Read table from CSV    orders.csv
    Log    Orders Obtained.
    [Return]    ${orders}

Close the annoying modal
    Click Button    OK
    Log    Modal Dismissed.

Fill the form
    [Arguments]    ${order}
    Select From List By Index    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    ${form-name}=    Get Element Attribute    class:form-control     name
    Input Text    ${form-name}    ${order}[Legs]
    Input Text    address    ${order}[Address]

Preview the robot
    Click Button    preview

Submit the order
    Click Button    order
    Page Should Contain Button    order-another

Store the receipt as a PDF file
    [Arguments]    ${order-number}
    ${receipt-html}=    Get Element Attribute    id:order-completion    outerHTML
    Html To Pdf    ${receipt-html}    ${OUTPUT_DIR}${/}Receipts${/}${order-number}-Receipt.pdf
    [Return]    ${OUTPUT_DIR}${/}Receipts${/}${order-number}-Receipt.pdf

Take a screenshot of the robot
    [Arguments]    ${order-number}
    Wait Until Element Is Visible    robot-preview
    Screenshot    robot-preview    ${OUTPUT_DIR}${/}Screenshots${/}${order-number}-Screenshot.png
    Log    Screenshot capture.
    [Return]    ${OUTPUT_DIR}${/}Screenshots${/}${order-number}-Screenshot.png  

Embed the robot screenshot to the receipt PDF file
    [Arguments]    ${screenshot}    ${pdf}
    Open Pdf    ${pdf}
    Add Watermark Image To Pdf    ${screenshot}    ${pdf}
    Close Pdf    ${pdf}

Go to order another robot
    Click Button    order-another

Create a ZIP file of the receipts
    ${zip_file_name}=    Set Variable    ${OUTPUT_DIR}${/}PDFs.zip
    Archive Folder With Zip    ${OUTPUT_DIR}${/}Receipts    ${zip_file_name}