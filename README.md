# json-sl
json-sl is a project that adds dynamic things to JSON. json-sl
will take a JSON file with added features, and output JSON
without added features.

# Requiring json-sl as an NPM Module:
Well, I guess you can install it like this:
```
npm i json-sl
```

K..

The `json-sl` module is a function that takes in JSON and spits out, well, different JSON. Maybe use it like this:
```
    require('json-sl')({
        "foo": "rand(0,10)",
        "foo[,3]": ".You Lose!",
        "foo[3,7]": ".You Win!",
        "foo[7,]": ".You Tie!"
    });
```

# Features
* Perform math using these operators: `!%^*/+-()`
* Generate random data using the `rand(min,max)` function.
* Reference properties using their names. `my.attack - opp.defense`
* Use `parent` to walk up. `parent.age`
* Use `prop[0,5]` as a property name to overwrite `prop` if the current value is between 0-5.


# Install from Git
You should have Node.js, NPM, and the 'git' command.
These are instructions for linux, and you may have to 
change some things for Windows.

open a Terminal and use `cd` to get to the place where 
you want the `json-sl` folder to be downloaded.
```
git clone https://github.com/s-p-n/json-sl
cd json-sl
npm i
```


# Running in the Terminal
To run this, get your terminal into the `json-sl` directory.
Once you are there, pass a JSON file to run it like below:
```
node run data/attack.json
```

There are some JSON files that work in the `data` directory.
Those work well as examples. Try copying one, making changes,
and creating something new and interesting.



## Enjoy!
