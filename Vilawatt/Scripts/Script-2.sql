REFRESH MATERIALIZED VIEW mv_cyclos_users;
SELECT * FROM mv_cyclos_users mcu WHERE dni ~ '52918130Y';
SELECT * FROM mv_cyclos_users mcu WHERE username ~ 'malore'