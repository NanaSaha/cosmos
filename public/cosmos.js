document.addEventListener('DOMContentLoaded', function () {
    const searchButton = document.getElementById('searchButton');

    const reloadBtn = document.getElementById('reloadBtn');
    const destinationFilter = document.getElementById('destinationFilter');
    const airlineFilter = document.getElementById('airlineFilter');
    const flightTableBody = document.getElementById('flightTableBody');

    const emptyNotice = document.getElementById('emptyNotice');

    searchButton.addEventListener('click', function () {
        const destination = destinationFilter.value;
        const airline = airlineFilter.value;

        // AJAX request to the API
        fetch('/api/flights', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({
                destination: destination.toUpperCase(),
                airline: airline.toUpperCase()
            })
        })
            .then(response => response.json())
            .then(data => {
                // Clear existing rows
                flightTableBody.innerHTML = '';

                console.log("data coming -- ", data)

                if (data.length === 0) {
                    // Show the empty notice
                    emptyNotice.style.display = 'block';
                } else {
                    // Hide the empty notice if there are results
                    emptyNotice.style.display = 'none';

                    // Populate the table with the filtered data
                    data.forEach(flight => {
                        const row = document.createElement('tr');

                        const flightNumberCell = document.createElement('td');
                        flightNumberCell.textContent = flight['flight_number'];
                        row.appendChild(flightNumberCell);

                        const airlineCell = document.createElement('td');
                        airlineCell.textContent = flight['airline'];
                        row.appendChild(airlineCell);

                        const originCell = document.createElement('td');
                        originCell.textContent = flight['origin'];
                        row.appendChild(originCell);

                        const destinationCell = document.createElement('td');
                        destinationCell.textContent = flight['destination'];
                        row.appendChild(destinationCell);

                        const scheduledDepartureCell = document.createElement('td');
                        scheduledDepartureCell.textContent = flight['scheduled_departure_at'];
                        row.appendChild(scheduledDepartureCell);

                        const actualDepartureCell = document.createElement('td');
                        actualDepartureCell.textContent = flight['actual_departure_at'];
                        row.appendChild(actualDepartureCell);

                        const delaysCell = document.createElement('td');
                        const delayList = document.createElement('ul');
                        flight['delays'].forEach(delay => {
                            const delayItem = document.createElement('li');
                            delayItem.textContent = `${delay['description']} (${delay['time_minutes']} minutes)`;
                            delayList.appendChild(delayItem);
                        });
                        delaysCell.appendChild(delayList);
                        row.appendChild(delaysCell);

                        flightTableBody.appendChild(row);
                    });

                }
            })
            .catch(error => console.error('Error fetching flight data:', error));


    });




    reloadBtn.addEventListener('click', function () {
        window.location.href = '/';
    });



});



   
    // function filterFlights() {
    //     const destinationFilter = document.getElementById('destinationFilter').value.toUpperCase();
    //     const airlineFilter = document.getElementById('airlineFilter').value.toUpperCase();
    //     const table = document.getElementById('flightTable');
    //     const tr = table.getElementsByTagName('tr');

    //     for (let i = 1; i < tr.length; i++) {
    //         const tdDestination = tr[i].getElementsByTagName('td')[3];
    //         const tdAirline = tr[i].getElementsByTagName('td')[1];
    //         if (tdDestination && tdAirline) {
    //             const destinationValue = tdDestination.textContent || tdDestination.innerText;
    //             const airlineValue = tdAirline.textContent || tdAirline.innerText;

    //             if (destinationValue.toUpperCase().indexOf(destinationFilter) > -1 &&
    //                 airlineValue.toUpperCase().indexOf(airlineFilter) > -1) {
    //                 tr[i].style.display = "";
    //             } else {
    //                 tr[i].style.display = "none";
    //             }
    //         }
    //     }
    // }
