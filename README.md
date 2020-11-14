# MT5763_Shiny

## Overview

This project was created as part of the MT5763 coursework at the University of St Andrews. The repository contains the files required to scrape data on the Premier League from several sources. The data scraped includes:
* The current table, complete with the usual data (games played, won, drawn, lost, points, goal difference, goals for, goals against, position) from the official premier league website.
* The current market value of the premier league clubs (in millions of euros) from Transfermarkt.
* The co-ordinates for the home ground of each premier league club, scraped from Wikipedia.
The licenses for all websites were checked beforehand and all allow web-scraping.

The scraped data is then visualised in three ways which the user can interact with:
* A table which can be ordered by any of the variables, in ascending or descending order.
* A scatter plot, which adds in market value, of any of the variables on the x-axis and points of the y-axis.
* A map of England which visualises how well each clubs are doing by displaying red or green circles where their home ground is located.

The app also includes:
* A download dataset button which allows the user to download the live, manipulated data as a csv file.
* A refresh button which reperforms the scraping functions to ensure data is up-to-date
* Functionality to automatically refresh every hour.

## File Description

### Scraper

Includes all the functions which scrape the required data from the web. This folder includes a file for each website:
* getPremTable.R - accesses the official premier league table
* getMarketValue.R - accesses Transfermarkt to scrape clubs' market values
* getCoords.R - accesses Wikipedia to scrape clubs' coordinates

### DESCRIPTION

Basic file which allows app to be used in showcase mode and credits the authors of the app

### global.R

File containing the global functions which are used by the Shiny server. Main function in this file is getData() which accesses the scraping functions and outputs them in the desired format. Including getData() in global as opposed to being built into the server makes code more modular and improves readability of server file.

### server.R

Server file which defines how the shiny app works.

### ui.R

UI file which defines how the shiny app looks.

### test_scrapers.R

File which outputs the scraping functions to test whether they are working.








