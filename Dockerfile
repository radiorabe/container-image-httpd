FROM quay.io/netboxcommunity/netbox:v3.1.7@sha256:a65b7570fc8367a9f2cfc3bda8278b0fa0f26ee15b4192e0511390e4eb2b6210

COPY ./plugin_requirements.txt /opt/netbox/

COPY --from=ghcr.io/astral-sh/uv:0.12 /uv /usr/local/bin/
RUN /usr/local/bin/uv --directory /opt/netbox/venv pip install -r /opt/netbox/plugin_requirements.txt

RUN mkdir -p /opt/netbox/netbox/static/netbox_topology_views/img

RUN sed -i 's/PLUGINS\s=.*/PLUGINS = \["netbox_topology_views"\]/' /etc/netbox/config/configuration.py

RUN DEBUG="true" SECRET_KEY="dummydummydummydummydummydummydummydummydummydummy" \
    /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py collectstatic --no-input
