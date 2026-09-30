FROM quay.io/netboxcommunity/netbox:v4.7.2@sha256:ad038bdb0e3498e5bf81c2c8becf396d62cbdc118d0b491b4d58014968033066

COPY ./plugin_requirements.txt /opt/netbox/

COPY --from=ghcr.io/astral-sh/uv:0.12 /uv /usr/local/bin/
RUN /usr/local/bin/uv --directory /opt/netbox/venv pip install -r /opt/netbox/plugin_requirements.txt

RUN mkdir -p /opt/netbox/netbox/static/netbox_topology_views/img

RUN sed -i 's/PLUGINS\s=.*/PLUGINS = \["netbox_topology_views"\]/' /etc/netbox/config/configuration.py

RUN DEBUG="true" SECRET_KEY="dummydummydummydummydummydummydummydummydummydummy" \
    /opt/netbox/venv/bin/python /opt/netbox/netbox/manage.py collectstatic --no-input
