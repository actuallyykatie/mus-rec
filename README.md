# Music Recommender
> Data Science minor final project

[**Link**](vk.cc/9v83UO) to Shiny application zip. Includes:
- app.R - application
- w2v_90m - word2vec model *(3 files due to model size)*
- artistsChoice.csv - list of artists *(for app input)*

# Repository structure
- **models** - word2vec models; 10M only
- **notebooks** - notebooks
- **slides** - presentations
- **other** - code snippets and other stuff
- **app** - ~shiny application~ 🚧 --> vk.cc/9v83UO 


# Data 
Data: song playlists from SNs  
Example:

| user_id | song                      | artist         |
|:-------:|:-------------------------:|:--------------:|
| 1       | Bohemian Rhapsody         | Queen          |
| 1       | The Immigrant Song        | Led Zeppelin   |
| 2       | LaBelle                   | Lady Marmalade |
| 2       | Non! Je Ne Regrette Rien  | Edith Piaf     |
| 2       | On était beau             | Louane         |
| 2       | Город                     | PRAVADA        | 
| ...     | ...                       | ...            | 
| 968772  | Grand Piano               | Nicki Minaj    |
| 968772  | thank u, next             | Ariana Grande  |


# Methods
Method: word2vec skip-gram  
Idea: Each user's playlist is represented as a sentence, and if artists appear in the same playlists, they are similar and belong to the same context. The model takes artists as an input *(from one)*, and recommends *n* artists.   

The final model was trained on full dataset: approximately 90 000 000 user-item, 950 000 users, 9 hours.  

# Examples
Case: something epic for the one who loves Game of Thrones
```python
model_w2v.wv.most_similar('ramin djawadi', topn=10)
```

Model recommends other authors of soundtracks. Interesting case: soundtrack to 'the witcher 3 wild hunt' - 'The Trail' is quite similar to the TV series main song. 

```
[('drake',	0.6897857189178467),
('hans zimmer',	0.774951577186584),
('ramin djawadi',	0.761010468006134),
('westworld',	0.747692465782166),
('the witcher 3 wild hunt',	0.722944676876068),
('daniel pemberton',	0.721352934837341),
('howard shore',	0.719944596290588),
('jeremy soule',	0.715254724025726),
('two steps from hell',	0.711450159549713),
('hans zimmer',	0.709886014461517),
('akihiro honda',	0.703315019607544)]
```


Case: the one who listens to placebo and radiohead and is not in a good mood
```python
placebo_sim = [a[0].strip() for a in model_w2v.wv.most_similar(['placebo'], topn=15)]
placebo_sim
```

```
['iamx',
 'arctic monkeys',
 'blue october',
 'franz ferdinand',
 'radiohead',
 'the smiths',
 'the killers',
 'him',
 'the pretty reckless',
 '30 seconds to mars',
 'hypnogaja',
 'my chemical romance',
 'sea wolf',
 'she wants revenge',
 'stereophonics']
 ```
 
 And who does not match there?  
 human prediction: 'my chemical romance' or 'franz ferdinand'   
 model:
 ```python
 print(model_w2v.wv.doesnt_match(placebo_sim))
 ```
 ```
 my chemical romance
 ```
