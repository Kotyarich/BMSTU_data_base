alter table bd_labs.airports
    add constraint name_not_empty check ( name != '' ),
    add constraint country_not_empty check ( country != '' ),
    add constraint city_not_empty check ( city != '' );

alter table bd_labs.planes
    add constraint number_unique unique(number),
    add constraint positive_places check ( places > 0 ),
    add constraint model_not_empty check ( model != '' ),
    add constraint company_not_empty check ( company is null or company != '' );

alter table bd_labs.flights
    add constraint diff_airports check ( departure_airport_id != arrival_airport_id ),
    add constraint dep_earlier_arr check ( departure_time < arrival_time );

alter table bd_labs.tickets
    add constraint cost_not_neg check ( value::numeric > 0 );

alter table bd_labs.passengers
    add constraint sex_m_or_f check ( sex = 'm' or sex = 'f' ),
    add constraint passport_num_len check ( length(passport_number) = 10),
    add constraint name_not_empty check ( name != '' );