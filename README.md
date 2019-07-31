# Bowling API

## Creating game

* **URL**

    `/games`
    
* **method**    
    
    `POST`
    
* **Data params**

  `game: { players_list: [array of names] }`
  
* **Success response**

  * **Code:** 200 <br />
  **Content:** `{ id : 12 }`

* **Error response**

  * **Code:** 400 <br />
  **Content:** `{ errors : ['Players list is empty'] }`

## First bowl (creating frame) 

* **URL**

    `/games/:game_id/frames`
    
* **method**    
    
    `POST`
    
* **URL params**

    `game_id: [integer]`    
    
* **Data params**

  `frame: { player_id: [integer], points: [integer] }`
  
* **Success response**

  * **Code:** 200 <br />
  **Content:** `{ id : 12 }`

* **Error response**

  * **Code:** 400 <br />
  **Content:** `{ errors : ['Not closed frame exists'] }`

## Second and third bowls of frame (updating frame)

* **URL**

    `/games/:game_id/frames/:id`
    
* **method**    
    
    `PATCH`
    
* **URL params**

    `game_id: [integer]`
    
    `id: [integer]`        
    
* **Data params**

  `frame: { points: [integer] }`
  
* **Success response**

  * **Code:** 200 <br />

* **Error response**

  * **Code:** 400 <br />
  **Content:** `{ errors : ['Game is finished'] }`

## Get score of game 

* **URL**

    `/games/:id`
    
* **method**    
    
    `GET`
    
* **URL params**

    `id: [integer]`    
  
* **Success response**

  * **Code:** 200 <br />
  **Content:** 
  ~~~~
  {
    "id": 1,
    "started_at": "2019-07-31 21:32:12 UTC",
    "finished_at": null,
    "players": [
      {
        "name": "Player1",
        "id": 1,
        "total": 26,
        "frames": [
          {
            "id": 1,
            "number": 1,
            "first_bowl": 10,
            "second_bowl": null,
            "status": "strike",
            "total": 18
          },
          {
            "id": 2,
            "number": 2,
            "first_bowl": 8,
            "second_bowl": null,
            "status": "ordinary",
            "total": 8
          }
        ]
      },
      {
        "name": "Player1",
        "id": 2,
        "total": 15,
        "frames": [
          {
            "id": 3,
            "number": 10,
            "first_bowl": 7,
            "second_bowl": 3,
            "status": "ordinary",
            "total": 15,
            "third_bowl": 5
          }
        ]
      }
    ]
  }
  ~~~~
  
