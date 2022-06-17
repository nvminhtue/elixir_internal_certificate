#!/bin/sh

bin/elixir_internal_certificate eval "ElixirInternalCertificate.ReleaseTasks.migrate()"

bin/elixir_internal_certificate start
