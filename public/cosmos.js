document.addEventListener('DOMContentLoaded', function () {
    const srchbtn = document.getElementById('srchbtn');

    const bkBtn = document.getElementById('bkBtn');
    const filter_destination = document.getElementById('filter_destination');
    const filter_airline = document.getElementById('filter_airline');
    const getflightTableBody = document.getElementById('getflightTableBody');

    const nullinfo = document.getElementById('nullinfo');

    srchbtn.addEventListener('click', function () {
        const destination = filter_destination.value;
        const airline = filter_airline.value;

        // making AJAX request to the endpoint and changing all inputs to uppercase
        fetch('/cosmos/check_flights', {
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
                // clear all data in the table
                getflightTableBody.innerHTML = '';

                console.log("data coming -- ", data.error)

                if (data.length === 0 || data.error ) {
                    // Show the null info
                    nullinfo.style.display = 'block';
                } else {
                    // Hide the null information if there are results
                    nullinfo.style.display = 'none';

                    // Populate the table with the filtered data
                    data.forEach(flight => {
                        const row = document.createElement('tr');

                        const flightNumberTd = document.createElement('td');
                        flightNumberTd.textContent = flight['flight_number'];
                        row.appendChild(flightNumberTd);

                        const airlineTd = document.createElement('td');
                        airlineTd.textContent = flight['airline'];
                        row.appendChild(airlineTd);

                        const originTd = document.createElement('td');
                        originTd.textContent = flight['origin'];
                        row.appendChild(originTd);

                        const destinationTd = document.createElement('td');
                        destinationTd.textContent = flight['destination'];
                        row.appendChild(destinationTd);

                        const scheduledDepartureTd = document.createElement('td');
                        scheduledDepartureTd.textContent = flight['scheduled_departure_at'];
                        row.appendChild(scheduledDepartureTd);

                        const actualDepartureTd = document.createElement('td');
                        actualDepartureTd.textContent = flight['actual_departure_at'];
                        row.appendChild(actualDepartureTd);

                        const delaysTd = document.createElement('td');
                        const delayList = document.createElement('ul');
                        flight['delays'].forEach(delay => {
                            const delayItem = document.createElement('li');
                            delayItem.textContent = `${delay['description']} (${delay['time_minutes']} minutes)`;
                            delayList.appendChild(delayItem);
                        });
                        delaysTd.appendChild(delayList);
                        row.appendChild(delaysTd);

                        getflightTableBody.appendChild(row);
                    });

                }
            })
            .catch(error => console.error('Error fetching data:', error));


    });




    bkBtn.addEventListener('click', function () {
        window.location.href = '/';
    });



});