*** Settings ***
Library           RPA.Browser.Selenium
Library           RPA.HTTP
Library           RPA.Tables
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
        Submit the order
    #     ${pdf}=    Store the receipt as a PDF file    ${row}[Order number]
    #     ${screenshot}=    Take a screenshot of the robot    ${row}[Order number]
    #     Embed the robot screenshot to the receipt PDF file    ${screenshot}    ${pdf}
        Go to order another robot
    END
    # Create a ZIP file of the receipts

*** Keywords ***
Open the robot order website
    Open Available Browser    https://robotsparebinindustries.com/
    Log    Website Opened.

Get orders
    Download    https://robotsparebinindustries.com/orders.csv    overwrite=True
    ${orders}=    Read table from CSV    orders.csv
    Log    Orders Obtained.
    [Return]    ${orders}


Close the annoying modal
    Open Available Browser    https://robotsparebinindustries.com/#/robot-order
    Click Button    OK
    Log    Modal Dismissed.

Fill the form
    [Arguments]    ${order}
    Select From List By Index    head    ${order}[Head]
    Select Radio Button    body    ${order}[Body]
    # Select from List by Value    1650594198635    ${order}[Legs]
    Input Text    address    ${order}[Address]

Preview the robot
    Click Button    preview

Submit the order
    Click Button    order

Go to order another robot
    Click Button    order-another
