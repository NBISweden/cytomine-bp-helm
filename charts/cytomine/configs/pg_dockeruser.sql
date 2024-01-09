DO
$do$
BEGIN
   IF EXISTS (
      SELECT FROM pg_catalog.pg_roles
      WHERE  rolname = '{{ .Values.postgresql.user }}') THEN

      RAISE NOTICE 'Role "{{ .Values.postgresql.user }}" already exists. Skipping.';
   ELSE
      CREATE ROLE {{ .Values.postgresql.user }} LOGIN PASSWORD '{{ .Values.postgresql.password }}';
   END IF;
END
$do$;

