{% from 'desktop/user/lib.sls' import user, user_info, user_home with context %}

lacells-creator:
  pkg.installed:
    - pkgs:
      - php5-cli
      - sqlite3
      - wget

  git.latest:
    - name: https://github.com/n76/lacells-creator.git
    - target: {{ user_home }}/work/lacells-creator
    - user: {{ user }}
    - unless: test -d {{ user_home }}/work/lacells-creator
    - require:
      - pkg: lacells-creator

{% for a in ['gen_lacells', 'gen_lacells_merged'] %}
{{ user_home }}/work/lacells-creator/{{ a }}:
  file.replace:
    - pattern: "^API_KEY[ ]*=.*$"
    - repl: "API_KEY='{{ pillar['opencellid']['api_key'] }}'"
{% endfor %}

{#
make-cell-db:
  cmd.run:
    - name: zcat towers_*.gz | grep -E "^[^,]+,2[0-9]+" | cut -d, -f 2-5,7-10 | sort -S "25%" -t, -u -k1 -k2 -k3 -k4 | gzip > combined_towers.gz

   next step: import into sqlite3 with min(max) ; export to csv; clean import again 

# wanted order: decompress cat cut grep sort compress

# remove header: "radio,mcc,net,area,cell,unit,lon,lat,range,samples,changeable,created,updated,averageSignal"
# remove header: "radio,*mcc,*net,*area,*cell,unit,*lon,*lat,*range,*samples,changeable,created,updated,averageSignal"
# cut out radio, unit, changeable,created,updated, averageSignal
# range: min(max(range, 500),100000)
# samples: max(1,samples)
# altitude: -1
# mcc INTEGER, mnc INTEGER, lac INTEGER, cid INTEGER, longitude REAL, latitude REAL, altitude REAL, accuracy REAL, samples INTEGER
# 
mcc INTEGER, mnc INTEGER, lac INTEGER, cid INTEGER, longitude REAL, latitude REAL, altitude REAL, accuracy REAL, samples INTEGER
radio TEXT, mcc INTEGER, mnc INTEGER, lac INTEGER, cellId INTEGER, unit TEXT, long REAL, lat REAL, range INTEGER, samples INTEGER, changeable BOOL, created INTEGER, updated INTEGER, averageSignalStrength INTEGER

.mode csv
.import towers_opencellid.csv cells_new
INSERT INTO cells SELECT mcc, mnc, lac, cellid, long, lat, -1, min(max(range, 500),100000), max(1,samples) FROM cells_new;

# mmc of austria and surrounding
# 2xx
#
# 216 hungary
# 228 switzerland
# 230 czech republic
# 231 slovakia
# 232 austria
# 234 UK
# 235 UK
# 238 Denmark
# 240 Sweden
# 242 norway
# 244 finland
# 262 germany


