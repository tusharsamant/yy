CREATE TABLE feed (
  feedurl text primary key,
  name text not null unique,
  folder text not null default 'inbox',
  period text not null default '1 hours',
  requested datetime,
  retrieved datetime,
  processed datetime,
  content text
);
CREATE TABLE story (
  storylink text primary key,
  delivered datetime not null default CURRENT_TIMESTAMP,
  filename text not null
, feedurl references feed(feedurl));
