package main

import (
	"encoding/csv"
	"fmt"
	"io"
	"log"
	"os"
)

func main() {
	// Open the file
	csvfile, err := os.Open("input.csv")
	if err != nil {
		log.Fatalln("Couldn't open the csv file", err)
	}

	// Parse the file
	r := csv.NewReader(csvfile)

	// setup the map to hold a 'string' key with int/counter values
	m := make(map[string]int)

	// Iterate through the requests
	// headers: request_method,url,date_accessed,bytes_streamed

	for {
		// Read each 'request' from csv
		request, err := r.Read()
		if err == io.EOF {
			break
		}
		if err != nil {
			log.Fatal(err)
		}
		// fmt.Printf("method: %s , URL: %s , Date: %s , Bytes: %s \n", request[0], request[1], request[2], request[3])
		date := strings.Split(request[2], "T")
		d, _ := date[0]
		// Alternatively, parse the month (or the full date) from request[2]
		//	t, _ := time.Parse(layoutISO, request[2])
		// fmt.Println(t)                  // YYYY-MM-DD hh:mm:ss +0000 UTC
		// fmt.Println(t.Format(layoutUS)) // Month DD, YYYY
		//	d, _ := t.Format(layoutUS)
		// optionally parse the url for the resource name
		// Split on slash. -- could also split via RegEx but that seems overkill for this use case
		urlElements := strings.Split(request[1], "/")

		// RegEx option could look something like this:
		//   matched, err := regexp.MatchString(`a.b`, "aaxbb")
	
		// Length is 3, and the unique resource name is the 3rd element
		u, _ := urlElements[2]
		// create a key that includes the resource name and month (or date)
		// Example map entry -- sermon-2-2019-07-14 = n bytes
		k, _ := u + "-" + d
		// OR
		//  k, _ := request[1] + "-" + d		

		if v, found := m[k]; found {
			m[k] = v+request[3]
		} else {
			m[k] = request[3]
		}
	}

	scala> grades.valuesIterator.max
	maxValue, err := m.valuesIterator.max
	for key, value := range m {
		fmt.Println("Key:", key, "Value:", value)
	}

}